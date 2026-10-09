import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/features/ocr/services/date_parser.dart';

void main() {
  group('DateParser Unit Tests', () {
    test('Phân tích định dạng DD/MM/YYYY', () {
      const text = 'Ngày: 15/10/2024';
      final date = DateParser.parse(text);
      expect(date, equals('2024-10-15'));
    });

    test('Phân tích định dạng DD-MM-YYYY', () {
      const text = 'Ngay: 05-11-2024';
      final date = DateParser.parse(text);
      expect(date, equals('2024-11-05'));
    });

    test('Phân tích định dạng YYYY-MM-DD', () {
      const text = 'Date: 2024-07-18 14:30';
      final date = DateParser.parse(text);
      expect(date, equals('2024-07-18'));
    });

    test('Phân tích định dạng ngày có năm 2 chữ số DD/MM/YY', () {
      const text = 'TG: 25/11/24';
      final date = DateParser.parse(text);
      expect(date, equals('2024-11-25'));
    });

    test('Phân tích định dạng ngày tiếng Việt dạng "16 thg 3, 2022"', () {
      expect(DateParser.parse('16 thg 3, 2022'), equals('2022-03-16'));
      expect(DateParser.parse('Ngày: 16 thg 03, 2022'), equals('2022-03-16'));
      expect(DateParser.parse('16 thg. 3, 2022 14:30'), equals('2022-03-16'));
      expect(DateParser.parse('16 Thg 3 2022'), equals('2022-03-16'));
    });

    test('Phân tích định dạng ngày tiếng Việt có lỗi OCR số (O -> 0)', () {
      expect(DateParser.parse('16 thg O3, 2O22'), equals('2022-03-16'));
    });

    test('Bỏ qua ngày không hợp lệ (ví dụ: ngày 31/02)', () {
      const text = 'Ngày: 31/02/2024';
      final date = DateParser.parse(text);
      expect(date, isNull);
    });

    test('Trả về null cho văn bản không có ngày', () {
      expect(DateParser.parse(''), isNull);
      expect(DateParser.parse('Hóa đơn thanh toán tiền mặt'), isNull);
    });
  });
}