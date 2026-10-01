import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/core/constants/category_keywords.dart';
import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';

void main() {
  group('Category Keywords', () {
    test('every keyword maps to a valid ExpenseCategory', () {
      for (final entry in categoryKeywords.entries) {
        expect(
          ExpenseCategory.values.contains(entry.value),
          isTrue,
          reason: 'Keyword "${entry.key}" should map to a valid category',
        );
      }
    });

    test('at least one keyword exists for each category', () {
      for (final category in ExpenseCategory.values) {
        final hasKeyword = categoryKeywords.values.any((v) => v == category);
        expect(
          hasKeyword,
          isTrue,
          reason: 'Category ${category.name} should have at least one keyword',
        );
      }
    });

    test('Food category contains coffee keyword', () {
      expect(categoryKeywords['coffee'], ExpenseCategory.food);
    });

    test('Study category contains book keyword', () {
      expect(categoryKeywords['book'], ExpenseCategory.study);
    });

    test('Travel category contains grab keyword', () {
      expect(categoryKeywords['grab'], ExpenseCategory.travel);
    });

    test('Gear category contains laptop keyword', () {
      expect(categoryKeywords['laptop'], ExpenseCategory.gear);
    });

    test('Entertainment category contains cinema keyword', () {
      expect(categoryKeywords['cinema'], ExpenseCategory.entertainment);
    });

    test('all keywords are lowercase', () {
      for (final key in categoryKeywords.keys) {
        expect(
          key,
          equals(key.toLowerCase()),
          reason: 'Keyword "$key" should be lowercase',
        );
      }
    });

    test('defaultCategory is food', () {
      expect(defaultCategory, ExpenseCategory.food);
    });
  });
}
