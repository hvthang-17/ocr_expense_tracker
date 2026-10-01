import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ocr_expense_tracker/features/transaction/data/database_helper.dart';
import 'package:ocr_expense_tracker/features/transaction/data/expense_repository.dart';
import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';

void main() {
  // Cấu hình FFI để chạy sqflite test trên Desktop VM
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
        await db.execute(
          'CREATE INDEX idx_expenses_date ON expenses(transaction_date);',
        );
        await db.execute(
          'CREATE INDEX idx_expenses_category ON expenses(category);',
        );
      },
    );

    dbHelper = DatabaseHelper.forTest(db);
    repository = ExpenseRepository(dbHelper: dbHelper);
  });

  tearDown(() async {
    await db.close();
  });

  Expense makeSample({
    String merchant = 'Highlands Coffee',
    String transactionDate = '2026-09-12',
    int totalAmount = 150000,
    ExpenseCategory category = ExpenseCategory.food,
    String? thumbnailPath,
  }) {
    return Expense(
      merchant: merchant,
      transactionDate: transactionDate,
      totalAmount: totalAmount,
      category: category,
      thumbnailPath: thumbnailPath,
      createdAt: '2026-09-12T10:00:00Z',
      updatedAt: '2026-09-12T10:00:00Z',
    );
  }

  // ── CRUD ────────────────────────────────────────────────

  group('Insert', () {
    test('inserts record and returns auto-increment ID', () async {
      final id = await repository.insertExpense(makeSample());
      expect(id, greaterThan(0));
    });

    test('inserted record can be fetched by ID', () async {
      final id = await repository.insertExpense(makeSample());
      final fetched = await repository.getExpenseById(id);

      expect(fetched, isNotNull);
      expect(fetched!.id, id);
      expect(fetched.merchant, 'Highlands Coffee');
      expect(fetched.totalAmount, 150000);
      expect(fetched.category, ExpenseCategory.food);
      expect(fetched.transactionDate, '2026-09-12');
    });

    test('multiple inserts yield sequential IDs', () async {
      final id1 = await repository.insertExpense(makeSample());
      final id2 = await repository.insertExpense(
        makeSample(merchant: 'Starbucks'),
      );
      expect(id2, greaterThan(id1));
    });
  });

  group('Update', () {
    test('updates existing record fields', () async {
      final id = await repository.insertExpense(makeSample());
      final existing = (await repository.getExpenseById(id))!;

      final updated = existing.copyWith(
        merchant: 'Starbucks Coffee',
        totalAmount: 200000,
        category: ExpenseCategory.entertainment,
      );

      final affected = await repository.updateExpense(updated);
      expect(affected, equals(1));

      final reFetched = await repository.getExpenseById(id);
      expect(reFetched!.merchant, 'Starbucks Coffee');
      expect(reFetched.totalAmount, 200000);
      expect(reFetched.category, ExpenseCategory.entertainment);
    });

    test('throws ArgumentError when updating without ID', () async {
      final noId = makeSample();
      expect(
        () => repository.updateExpense(noId),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('Delete', () {
    test('deletes existing record', () async {
      final id = await repository.insertExpense(makeSample());
      final affected = await repository.deleteExpense(id);
      expect(affected, equals(1));

      final reFetched = await repository.getExpenseById(id);
      expect(reFetched, isNull);
    });

    test('returns 0 when deleting non-existent ID', () async {
      final affected = await repository.deleteExpense(9999);
      expect(affected, equals(0));
    });
  });

  group('GetById', () {
    test('returns null for non-existent ID', () async {
      final result = await repository.getExpenseById(9999);
      expect(result, isNull);
    });
  });

  // ── GetAll & Ordering ───────────────────────────────────

  group('GetAll', () {
    test('returns empty list when DB is empty', () async {
      final all = await repository.getAllExpenses();
      expect(all, isEmpty);
    });

    test('returns all records ordered by date DESC', () async {
      await repository.insertExpense(
        makeSample(transactionDate: '2026-09-01'),
      );
      await repository.insertExpense(
        makeSample(transactionDate: '2026-09-15'),
      );
      await repository.insertExpense(
        makeSample(transactionDate: '2026-09-10'),
      );

      final all = await repository.getAllExpenses();
      expect(all.length, equals(3));
      expect(all[0].transactionDate, '2026-09-15');
      expect(all[1].transactionDate, '2026-09-10');
      expect(all[2].transactionDate, '2026-09-01');
    });
  });

  // ── Search & Filter ────────────────────────────────────

  group('SearchAndFilter', () {
    test('filters by merchant query (case-insensitive)', () async {
      await repository.insertExpense(makeSample());
      await repository.insertExpense(
        makeSample(
          merchant: 'Fahasa Bookstore',
          category: ExpenseCategory.study,
        ),
      );
      final result =
          await repository.searchAndFilterExpenses(query: 'highlands');
      expect(result.length, equals(1));
      expect(result.first.merchant, 'Highlands Coffee');
    });

    test('filters by category', () async {
      await repository.insertExpense(makeSample());
      await repository.insertExpense(
        makeSample(merchant: 'Fahasa', category: ExpenseCategory.study),
      );
      final result = await repository.searchAndFilterExpenses(
        category: ExpenseCategory.study,
      );
      expect(result.length, equals(1));
      expect(result.first.category, ExpenseCategory.study);
    });

    test('filters by date range', () async {
      await repository.insertExpense(
        makeSample(transactionDate: '2026-09-01'),
      );
      await repository.insertExpense(
        makeSample(transactionDate: '2026-09-15'),
      );
      await repository.insertExpense(
        makeSample(transactionDate: '2026-09-30'),
      );
      final result = await repository.searchAndFilterExpenses(
        startDate: '2026-09-10',
        endDate: '2026-09-20',
      );
      expect(result.length, equals(1));
      expect(result.first.transactionDate, '2026-09-15');
    });

    test('combines all filters together', () async {
      await repository.insertExpense(makeSample());
      await repository.insertExpense(
        makeSample(
          merchant: 'Fahasa Bookstore',
          category: ExpenseCategory.study,
        ),
      );
      await repository.insertExpense(
        makeSample(transactionDate: '2026-08-01'),
      );
      final result = await repository.searchAndFilterExpenses(
        query: 'highlands',
        category: ExpenseCategory.food,
        startDate: '2026-09-01',
        endDate: '2026-09-30',
      );
      expect(result.length, equals(1));
      expect(result.first.merchant, 'Highlands Coffee');
    });

    test('returns empty list when no match', () async {
      await repository.insertExpense(makeSample());
      final result =
          await repository.searchAndFilterExpenses(query: 'nonexistent');
      expect(result, isEmpty);
    });

    test('returns all when no filter applied', () async {
      await repository.insertExpense(makeSample());
      await repository.insertExpense(
        makeSample(merchant: 'Fahasa', category: ExpenseCategory.study),
      );
      final result = await repository.searchAndFilterExpenses();
      expect(result.length, equals(2));
    });
  });

  // ── GetByDateRange ──────────────────────────────────────

  group('GetByDateRange', () {
    test('returns expenses within range inclusive', () async {
      await repository.insertExpense(
        makeSample(transactionDate: '2026-09-01'),
      );
      await repository.insertExpense(
        makeSample(transactionDate: '2026-09-10'),
      );
      await repository.insertExpense(
        makeSample(transactionDate: '2026-09-20'),
      );

      final result =
          await repository.getByDateRange('2026-09-01', '2026-09-10');
      expect(result.length, equals(2));
    });

    test('returns empty list when range has no data', () async {
      await repository.insertExpense(
        makeSample(transactionDate: '2026-09-15'),
      );

      final result =
          await repository.getByDateRange('2026-08-01', '2026-08-31');
      expect(result, isEmpty);
    });
  });

  // ── Category Totals ─────────────────────────────────────

  group('GetCategoryTotals', () {
    test('aggregates spending by category', () async {
      await repository.insertExpense(makeSample(totalAmount: 150000));
      await repository.insertExpense(makeSample(totalAmount: 50000));
      await repository.insertExpense(
        makeSample(
          merchant: 'Fahasa',
          totalAmount: 300000,
          category: ExpenseCategory.study,
        ),
      );

      final totals = await repository.getCategoryTotals();
      expect(totals[ExpenseCategory.food], equals(200000));
      expect(totals[ExpenseCategory.study], equals(300000));
      expect(totals[ExpenseCategory.travel], equals(0));
      expect(totals[ExpenseCategory.gear], equals(0));
      expect(totals[ExpenseCategory.entertainment], equals(0));
    });

    test('returns all zeros when DB is empty', () async {
      final totals = await repository.getCategoryTotals();
      for (final cat in ExpenseCategory.values) {
        expect(totals[cat], equals(0));
      }
    });

    test('filters by date range', () async {
      await repository.insertExpense(
        makeSample(transactionDate: '2026-09-01', totalAmount: 100000),
      );
      await repository.insertExpense(
        makeSample(transactionDate: '2026-10-15', totalAmount: 200000),
      );

      final totals = await repository.getCategoryTotals(
        startDate: '2026-10-01',
        endDate: '2026-10-31',
      );
      expect(totals[ExpenseCategory.food], equals(200000));
    });
  });

  // ── Weekly Totals ───────────────────────────────────────

  group('GetWeeklyTotals', () {
    test('returns correct number of weeks', () async {
      final result = await repository.getWeeklyTotals(numWeeks: 5);
      expect(result.length, equals(5));
    });

    test('each entry has required keys', () async {
      final result = await repository.getWeeklyTotals(numWeeks: 3);
      for (final week in result) {
        expect(week.containsKey('weekLabel'), isTrue);
        expect(week.containsKey('startDate'), isTrue);
        expect(week.containsKey('endDate'), isTrue);
        expect(week.containsKey('total'), isTrue);
      }
    });

    test('labels are sequential T1..TN', () async {
      final result = await repository.getWeeklyTotals(numWeeks: 4);
      expect(result[0]['weekLabel'], 'T1');
      expect(result[1]['weekLabel'], 'T2');
      expect(result[2]['weekLabel'], 'T3');
      expect(result[3]['weekLabel'], 'T4');
    });

    test('returns zero totals when no expenses exist', () async {
      final result = await repository.getWeeklyTotals(numWeeks: 3);
      for (final week in result) {
        expect(week['total'], equals(0));
      }
    });
  });
}
