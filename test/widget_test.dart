import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/app.dart';
import 'package:ocr_expense_tracker/features/transaction/data/database_helper.dart';
import 'package:ocr_expense_tracker/features/transaction/data/expense_repository.dart';
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

  Widget buildTestableApp() {
    return ProviderScope(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(repository),
      ],
      child: const ExpenseTrackerApp(),
    );
  }

  testWidgets('App renders MainNavigation with bottom nav',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableApp());
    await tester.pump();

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Lịch sử'), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
  });

  testWidgets('Bottom nav switches between Dashboard and History',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableApp());
    await tester.pump();

    expect(find.text('Dashboard'), findsWidgets);

    await tester.tap(find.text('Lịch sử'));
    await tester.pump();

    expect(find.text('Lịch sử giao dịch'), findsWidgets);
  });
}




