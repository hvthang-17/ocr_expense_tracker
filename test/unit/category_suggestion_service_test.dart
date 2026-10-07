import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/features/ocr/services/category_suggestion_service.dart';
import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';

void main() {
  group('CategorySuggestionService Unit Tests', () {
    test('Gợi ý Food từ tên thương hiệu cà phê (Highlands)', () {
      final category = CategorySuggestionService.suggestCategory(
        merchant: 'HIGHLANDS COFFEE',
      );
      expect(category, equals(ExpenseCategory.food));
    });

    test('Gợi ý Travel từ tên Grab trong merchant', () {
      final category = CategorySuggestionService.suggestCategory(
        merchant: 'GRAB VIETNAM',
      );
      expect(category, equals(ExpenseCategory.travel));
    });

    test('Gợi ý Study từ từ khóa nhà sách trong merchant', () {
      final category = CategorySuggestionService.suggestCategory(
        merchant: 'NHÀ SÁCH FAHASA',
      );
      expect(category, equals(ExpenseCategory.study));
    });

    test('Gợi ý Gear từ thương hiệu FPT Shop', () {
      final category = CategorySuggestionService.suggestCategory(
        merchant: 'FPT SHOP',
      );
      expect(category, equals(ExpenseCategory.gear));
    });

    test('Gợi ý Entertainment từ thương hiệu CGV Cinema', () {
      final category = CategorySuggestionService.suggestCategory(
        merchant: 'CGV CINEMA VIETNAM',
      );
      expect(category, equals(ExpenseCategory.entertainment));
    });

    test('Gợi ý danh mục dựa trên từ khóa trong rawText khi merchant rỗng', () {
      final category = CategorySuggestionService.suggestCategory(
        merchant: '',
        rawText: 'Biên lai mua chuột máy tính không dây 450.000đ',
      );
      expect(category, equals(ExpenseCategory.gear));
    });

    test('Dự phòng về Food khi không khớp bất kỳ từ khóa nào', () {
      final category = CategorySuggestionService.suggestCategory(
        merchant: 'CỬA HÀNG LẠ XYZ',
        rawText: 'Sản phẩm 123456 thanh toán 50.000đ',
      );
      expect(category, equals(ExpenseCategory.food));
    });
  });
}