import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/features/ocr/services/amount_parser.dart';

void main() {
  group('AmountParser Unit Tests', () {
    test('Phân tích tổng tiền từ dòng có từ khóa TỔNG CỘNG', () {
      const text = '''
HIGHLANDS COFFEE
1x Cà phê sữa 35.000
--------------------
TỔNG CỘNG: 35.000 VND
''';
      final amount = AmountParser.parse(text);
      expect(amount, equals(35000));
    });

    test('Phân tích tổng tiền từ từ khóa THÀNH TIỀN với ký hiệu đ', () {
      const text = '''
CIRCLE K
THÀNH TIỀN: 150.000 đ
''';
      final amount = AmountParser.parse(text);
      expect(amount, equals(150000));
    });

    test('Phân tích tổng tiền khi từ khóa ở dòng trên, số tiền ở dòng dưới', () {
      const text = '''
WINMART+
TONG TIEN:
185.000 VND
''';
      final amount = AmountParser.parse(text);
      expect(amount, equals(185000));
    });

    test('Phân tích từ khóa tiếng Anh TOTAL', () {
      const text = '''
STARBUCKS
TOTAL: 115,000 VNĐ
''';
      final amount = AmountParser.parse(text);
      expect(amount, equals(115000));
    });

    test('Bỏ qua số điện thoại và mã số thuế khi tìm tổng tiền', () {
      const text = '''
CỬA HÀNG ABC
MST: 0311293841
SĐT: 0909123456
TỔNG: 250.000 VND
''';
      final amount = AmountParser.parse(text);
      expect(amount, equals(250000));
    });

    test('Trả về null khi văn bản rỗng hoặc không có số tiền', () {
      expect(AmountParser.parse(''), isNull);
      expect(AmountParser.parse('   '), isNull);
      expect(AmountParser.parse('Không có số tiền ở đây'), isNull);
    });
  });
}