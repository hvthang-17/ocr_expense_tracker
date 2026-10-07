import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/features/ocr/services/merchant_parser.dart';

void main() {
  group('MerchantParser Unit Tests', () {
    test('Lấy tên cửa hàng ở dòng đầu tiên', () {
      const text = '''
HIGHLANDS COFFEE
CH Lê Văn Sỹ
Ngày: 15/10/2024
''';
      final merchant = MerchantParser.parse(text);
      expect(merchant, equals('HIGHLANDS COFFEE'));
    });

    test('Bỏ qua dòng tiêu đề hóa đơn và mã số thuế để lấy tên thương hiệu', () {
      const text = '''
HÓA ĐƠN BÁN HÀNG
MST: 0311293841
CIRCLE K VIETNAM
Ngày: 20/09/2024
''';
      final merchant = MerchantParser.parse(text);
      expect(merchant, equals('CIRCLE K VIETNAM'));
    });

    test('Bỏ qua dòng chứa thông tin địa chỉ và số điện thoại', () {
      const text = '''
SĐT: 0243.888.9999
ĐC: 88 Hoàng Hoa Thám
WINMART+
TỔNG: 185.000
''';
      final merchant = MerchantParser.parse(text);
      expect(merchant, equals('WINMART+'));
    });

    test('Trả về null khi văn bản rỗng hoặc chỉ có dòng rác', () {
      expect(MerchantParser.parse(''), isNull);
      expect(MerchantParser.parse('------------------\n=============='), isNull);
    });
  });
}