import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/features/transaction/data/database_helper.dart';
import 'package:ocr_expense_tracker/features/transaction/data/expense_repository.dart';
import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';
import 'package:ocr_expense_tracker/features/transaction/presentation/transaction_detail_screen.dart';
import 'package:ocr_expense_tracker/features/transaction/providers/expense_providers.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late DatabaseHelper dbHelper;
  late ExpenseRepository repository;

  setUp(() async {
    db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            merchant TEXT NOT NULL,
            transaction_date TEXT NOT NULL,
            total_amount INTEGER NOT NULL,
            category TEXT NOT NULL,
            thumbnail_path TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    );

    dbHelper = DatabaseHelper.forTest(db);
    repository = ExpenseRepository(dbHelper: dbHelper);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  Expense sampleExpense({int id = 1}) {
    return Expense(
      id: id,
      merchant: 'Phúc Long Coffee',
      transactionDate: '2026-09-15',
      totalAmount: 85000,
      category: ExpenseCategory.food,
      createdAt: '2026-09-15T12:00:00Z',
      updatedAt: '2026-09-15T12:00:00Z',
    );
  }

  Widget createWidgetUnderTest(Expense expense) {
    return ProviderScope(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        home: TransactionDetailScreen(
          transactionId: expense.id!,
          initialExpense: expense,
        ),
      ),
    );
  }

  testWidgets('displays merchant, formatted amount, category, and date',
      (WidgetTester tester) async {
    final expense = sampleExpense();
    await tester.pumpWidget(createWidgetUnderTest(expense));
    await tester.pumpAndSettle();

    expect(find.text('Phúc Long Coffee'), findsOneWidget);
    expect(find.text('85.000 VND'), findsOneWidget);
    expect(find.text('Food'), findsWidgets);
    expect(find.text('15/09/2026'), findsOneWidget);
    expect(find.text('Không có ảnh biên lai'), findsOneWidget);
  });

  testWidgets('tapping edit icon navigates to edit screen',
      (WidgetTester tester) async {
    final expense = sampleExpense();
    await tester.pumpWidget(createWidgetUnderTest(expense));
    await tester.pumpAndSettle();

    final editIconButton = find.byIcon(Icons.edit_outlined);
    expect(editIconButton, findsOneWidget);

    await tester.tap(editIconButton);
    await tester.pumpAndSettle();

    expect(find.text('Chỉnh sửa giao dịch'), findsOneWidget);
    expect(find.text('Cập nhật giao dịch'), findsOneWidget);
  });

  testWidgets('tapping delete icon shows confirmation dialog',
      (WidgetTester tester) async {
    final expense = sampleExpense();
    await tester.pumpWidget(createWidgetUnderTest(expense));
    await tester.pumpAndSettle();

    final deleteIconButton = find.byIcon(Icons.delete_outline);
    expect(deleteIconButton, findsOneWidget);

    await tester.tap(deleteIconButton);
    await tester.pumpAndSettle();

    expect(find.text('Xóa giao dịch'), findsOneWidget);
    expect(find.textContaining('Bạn có chắc chắn muốn xóa'), findsOneWidget);
    expect(find.text('Hủy'), findsOneWidget);
    expect(find.text('Xóa'), findsOneWidget);

    // Hủy thao tác xóa.
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();

    expect(find.text('Xóa giao dịch'), findsNothing);
    expect(find.text('Phúc Long Coffee'), findsOneWidget);
  });

  testWidgets('confirming delete calls repository delete and pops screen',
      (WidgetTester tester) async {
    int id = 0;
    await tester.runAsync(() async {
      id = await repository.insertExpense(sampleExpense());
    });
    final expense = sampleExpense(id: id);

    await tester.pumpWidget(createWidgetUnderTest(expense));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Xóa'));
    await tester.pump();
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 500)));
    await tester.pumpAndSettle();

    Expense? remaining;
    await tester.runAsync(() async {
      remaining = await repository.getExpenseById(id);
    });
    expect(remaining, isNull);
  });
}
