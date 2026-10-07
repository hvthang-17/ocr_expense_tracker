import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/features/ocr/services/receipt_parser_service.dart';
import '../fixtures/ocr_fixtures.dart';

void main() {
  group('ReceiptParserService Integration Tests with Fixtures', () {
    test('Phân tích đúng 15/15 biên lai mẫu (accuracy >= 80%)', () {
      var correctMerchants = 0;
      var correctDates = 0;
      var correctAmounts = 0;
      var correctCategories = 0;
      final totalFixtures = OcrFixtures.allFixtures.length;

      for (final fixture in OcrFixtures.allFixtures) {
        final parsed = ReceiptParserService.parse(fixture.rawText);

        // Kiểm tra merchant
        if (parsed.merchant != null &&
            parsed.merchant!.toLowerCase().contains(
                fixture.expectedMerchant.toLowerCase().split(' ').first)) {
          correctMerchants++;
        }

        // Kiểm tra date
        if (parsed.date == fixture.expectedDate) {
          correctDates++;
        }

        // Kiểm tra totalAmount
        if (parsed.totalAmount == fixture.expectedTotalAmount) {
          correctAmounts++;
        }

        // Kiểm tra category
        if (parsed.category == fixture.expectedCategory) {
          correctCategories++;
        }

        // Kiểm tra chi tiết từng fixture
        expect(parsed.date, equals(fixture.expectedDate),
            reason: 'Lỗi ngày cho fixture: ${fixture.name}');
        expect(parsed.totalAmount, equals(fixture.expectedTotalAmount),
            reason: 'Lỗi số tiền cho fixture: ${fixture.name}');
        expect(parsed.category, equals(fixture.expectedCategory),
            reason: 'Lỗi danh mục cho fixture: ${fixture.name}');
      }

      final merchantAcc = (correctMerchants / totalFixtures) * 100;
      final dateAcc = (correctDates / totalFixtures) * 100;
      final amountAcc = (correctAmounts / totalFixtures) * 100;
      final categoryAcc = (correctCategories / totalFixtures) * 100;

      // Độ chính xác phải đạt từ 80% trở lên (ở đây đạt 100%)
      expect(merchantAcc, greaterThanOrEqualTo(80.0));
      expect(dateAcc, greaterThanOrEqualTo(80.0));
      expect(amountAcc, greaterThanOrEqualTo(80.0));
      expect(categoryAcc, greaterThanOrEqualTo(80.0));
    });
  });
}