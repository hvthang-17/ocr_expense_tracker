import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/features/ocr/services/amount_parser.dart';
import 'package:ocr_expense_tracker/features/ocr/services/date_parser.dart';
import 'package:ocr_expense_tracker/features/ocr/services/ocr_text_cleaner.dart';
import 'package:ocr_expense_tracker/features/ocr/services/receipt_parser_service.dart';

void main() {
  group('OcrTextCleaner Unit Tests', () {
    test('Sửa lỗi O thay 0 trong số tiền', () {
      const text = 'TỔNG CỘNG: 65.OOO VND';
      final cleaned = OcrTextCleaner.clean(text);
      expect(cleaned, contains('65.000'));
    });

    test('Sửa lỗi l/I thay 1 trong số tiền', () {
      const text = 'THÀNH TIỀN: l50.000 đ';
      final cleaned = OcrTextCleaner.clean(text);
      expect(cleaned, contains('150.000'));
    });

    test('Sửa lỗi S thay 5 trong số tiền', () {
      const text = 'TỔNG: S0.000 VND';
      final cleaned = OcrTextCleaner.clean(text);
      expect(cleaned, contains('50.000'));
    });

    test('Chuẩn hóa khoảng trắng chèn giữa nhóm chữ số ngàn', () {
      const text = 'TỔNG CỘNG: 1 500 000 VND';
      final normalized = OcrTextCleaner.normalizeSpacedDigits(text);
      expect(normalized, contains('1.500.000'));
    });
  });

  group('OCR Parsing Accuracy with Real-World Misreads', () {
    test('Phân tích số tiền khi OCR đọc nhầm O thay 0', () {
      const text = '''
HIGHLANDS COFFEE
TỔNG CỘNG: 65.OOO VND
''';
      final cleaned = OcrTextCleaner.clean(text);
      final amount = AmountParser.parse(cleaned);
      expect(amount, equals(65000));
    });

    test('Phân tích số tiền khi OCR chèn khoảng trắng giữa nhóm số ngàn', () {
      const text = '''
CIRCLE K VIETNAM
THÀNH TIỀN: 1 500 000 đ
''';
      final amount = AmountParser.parse(text);
      expect(amount, equals(1500000));
    });

    test('Phân tích số tiền khi OCR đọc nhầm l thay 1 và S thay 5', () {
      const text = '''
PHÚC LONG TEA
TOTAL: lS0.000 VNĐ
''';
      final cleaned = OcrTextCleaner.clean(text);
      final amount = AmountParser.parse(cleaned);
      expect(amount, equals(150000));
    });

    test('Phân tích ngày tháng định dạng tiếng Việt: Ngày 15 tháng 10 năm 2024', () {
      const text = '''
WINMART+
Ngày 15 tháng 10 năm 2024
TỔNG: 185.000 VND
''';
      final date = DateParser.parse(text);
      expect(date, equals('2024-10-15'));
    });

    test('Phân tích đầy đủ biên lai nhiễu qua ReceiptParserService', () {
      const text = '''
HIGHLANDS COFFEE
HÓA ĐƠN BÁN HÀNG
Ngày: 15/1O/2024 14:30
1x Phin Sữa Đá (L) 4S.OOO
TỔNG CỘNG: 65.OOO VND
''';
      final parsed = ReceiptParserService.parse(OcrTextCleaner.clean(text));
      expect(parsed.merchant, equals('HIGHLANDS COFFEE'));
      expect(parsed.date, equals('2024-10-15'));
      expect(parsed.totalAmount, equals(65000));
    });
  });
}
