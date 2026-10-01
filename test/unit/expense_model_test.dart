import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';

void main() {
  group('ExpenseCategory', () {
    test('fromString returns correct category', () {
      expect(ExpenseCategory.fromString('food'), ExpenseCategory.food);
      expect(ExpenseCategory.fromString('study'), ExpenseCategory.study);
      expect(ExpenseCategory.fromString('travel'), ExpenseCategory.travel);
      expect(ExpenseCategory.fromString('gear'), ExpenseCategory.gear);
      expect(
        ExpenseCategory.fromString('entertainment'),
        ExpenseCategory.entertainment,
      );
    });

    test('fromString returns food for unknown value', () {
      expect(ExpenseCategory.fromString('unknown'), ExpenseCategory.food);
      expect(ExpenseCategory.fromString(''), ExpenseCategory.food);
    });

    test('each category has a non-empty label', () {
      for (final category in ExpenseCategory.values) {
        expect(category.label.isNotEmpty, isTrue);
      }
    });
  });

  group('Expense', () {
    final now = DateTime.now().toIso8601String();

    test('toMap and fromMap round-trip correctly', () {
      final expense = Expense(
        id: 1,
        merchant: 'Highlands Coffee',
        transactionDate: '2026-09-12',
        totalAmount: 150000,
        category: ExpenseCategory.food,
        thumbnailPath: '/path/to/image.jpg',
        createdAt: now,
        updatedAt: now,
      );

      final map = expense.toMap();
      final restored = Expense.fromMap(map);

      expect(restored.id, expense.id);
      expect(restored.merchant, expense.merchant);
      expect(restored.transactionDate, expense.transactionDate);
      expect(restored.totalAmount, expense.totalAmount);
      expect(restored.category, expense.category);
      expect(restored.thumbnailPath, expense.thumbnailPath);
    });

    test('toMap omits id when null', () {
      final expense = Expense(
        merchant: 'Test',
        transactionDate: '2026-01-01',
        totalAmount: 50000,
        category: ExpenseCategory.study,
        createdAt: now,
        updatedAt: now,
      );

      final map = expense.toMap();
      expect(map.containsKey('id'), isFalse);
    });

    test('copyWith overrides specified fields', () {
      final expense = Expense(
        id: 1,
        merchant: 'Old Merchant',
        transactionDate: '2026-01-01',
        totalAmount: 100000,
        category: ExpenseCategory.food,
        createdAt: now,
        updatedAt: now,
      );

      final updated = expense.copyWith(
        merchant: 'New Merchant',
        totalAmount: 200000,
      );

      expect(updated.merchant, 'New Merchant');
      expect(updated.totalAmount, 200000);
      // unchanged fields
      expect(updated.id, 1);
      expect(updated.transactionDate, '2026-01-01');
      expect(updated.category, ExpenseCategory.food);
    });

    test('equality works by value', () {
      final a = Expense(
        id: 1,
        merchant: 'Test',
        transactionDate: '2026-01-01',
        totalAmount: 100000,
        category: ExpenseCategory.food,
        createdAt: now,
        updatedAt: now,
      );
      final b = Expense(
        id: 1,
        merchant: 'Test',
        transactionDate: '2026-01-01',
        totalAmount: 100000,
        category: ExpenseCategory.food,
        createdAt: now,
        updatedAt: now,
      );

      expect(a, equals(b));
    });
  });
}
