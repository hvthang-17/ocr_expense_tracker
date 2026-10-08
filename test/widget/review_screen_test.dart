import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:ocr_expense_tracker/features/ocr/models/parsed_receipt.dart';
import 'package:ocr_expense_tracker/features/review/presentation/review_screen.dart';
import 'package:ocr_expense_tracker/features/transaction/data/database_helper.dart';
import 'package:ocr_expense_tracker/features/transaction/data/expense_repository.dart';
import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';
import 'package:ocr_expense_tracker/features/transaction/providers/expense_providers.dart';

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

  Widget buildTestableWidget({ParsedReceipt? parsedReceipt}) {
    return ProviderScope(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        home: ReviewScreen(parsedReceipt: parsedReceipt),
      ),
    );
  }

  group('ReviewScreen Widget Tests', () {
    testWidgets('Pre-fills form fields from complete ParsedReceipt', (tester) async {
      const receipt = ParsedReceipt(
        merchant: 'Highlands Coffee',
        date: '2024-10-15',
        totalAmount: 65000,
        category: ExpenseCategory.food,
        rawText: 'HIGHLANDS COFFEE\n15/10/2024\n65.000 VND',
      );

      await tester.pumpWidget(buildTestableWidget(parsedReceipt: receipt));
      await tester.pumpAndSettle();

      expect(find.text('Highlands Coffee'), findsOneWidget);
      expect(find.text('15/10/2024'), findsOneWidget);
      expect(find.text('65000'), findsOneWidget);
      expect(find.text('Lưu giao dịch'), findsOneWidget);

      final saveButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Lưu giao dịch'),
      );
      expect(saveButton.onPressed, isNotNull);
    });

    testWidgets('Shows warning indicators when ParsedReceipt has missing fields', (tester) async {
      const receipt = ParsedReceipt(
        merchant: null,
        date: null,
        totalAmount: null,
        category: null,
        rawText: 'Biên lai rác',
      );

      await tester.pumpWidget(buildTestableWidget(parsedReceipt: receipt));
      await tester.pumpAndSettle();

      expect(
        find.text('Một số thông tin chưa nhận dạng đầy đủ. Vui lòng bổ sung bên dưới.'),
        findsOneWidget,
      );

      final saveButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Lưu giao dịch'),
      );
      expect(saveButton.onPressed, isNull);
    });

    testWidgets('Shows validation errors when required fields are empty or invalid', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final amountField = find.widgetWithText(TextFormField, 'Tổng tiền (VND) *');
      await tester.enterText(amountField, '0');
      await tester.pumpAndSettle();

      expect(find.text('Số tiền phải lớn hơn 0'), findsOneWidget);
    });

    testWidgets('Selecting Category Chip updates selected category state', (tester) async {
      const receipt = ParsedReceipt(
        merchant: 'Grab Bike',
        date: '2024-10-15',
        totalAmount: 30000,
        category: ExpenseCategory.travel,
        rawText: 'GRAB BIKE 30.000 VND',
      );

      await tester.pumpWidget(buildTestableWidget(parsedReceipt: receipt));
      await tester.pumpAndSettle();

      final studyChip = find.text('Study');
      expect(studyChip, findsOneWidget);

      await tester.tap(studyChip);
      await tester.pumpAndSettle();
    });

    testWidgets('Saves expense into database when save button is clicked', (tester) async {
      const receipt = ParsedReceipt(
        merchant: 'FPT Shop',
        date: '2024-10-15',
        totalAmount: 1500000,
        category: ExpenseCategory.gear,
        rawText: 'FPT SHOP 1.500.000 VND',
      );

      await tester.pumpWidget(buildTestableWidget(parsedReceipt: receipt));
      await tester.pumpAndSettle();

      final saveButtonFinder = find.widgetWithText(FilledButton, 'Lưu giao dịch');
      expect(saveButtonFinder, findsOneWidget);

      await tester.tap(saveButtonFinder);
      await tester.pump();

      // Chạy trong vùng bất đồng bộ thực để hoàn tất thao tác FFI của sqflite.
      await tester.runAsync(() => Future.delayed(const Duration(seconds: 2)));
      await tester.pump();

      final allExpenses = await tester.runAsync(() => repository.getAllExpenses());
      expect(allExpenses, isNotNull);
      expect(allExpenses!.length, equals(1));
      expect(allExpenses.first.merchant, equals('FPT Shop'));
      expect(allExpenses.first.totalAmount, equals(1500000));
      expect(allExpenses.first.category, equals(ExpenseCategory.gear));
      expect(allExpenses.first.transactionDate, equals('2024-10-15'));
    });
  });
}

