import 'package:intl/intl.dart';

// Lớp tiện ích định dạng giá trị tiền tệ VND.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _vndFormat = NumberFormat('#,###', 'vi_VN');

  // Định dạng số nguyên (VND) thành chuỗi hiển thị.
  // Ví dụ: 150000 → '150,000 VND'
  static String format(int amount) {
    return '${_vndFormat.format(amount)} VND';
  }

  // Định dạng không kèm hậu tố tiền tệ.
  // Ví dụ: 150000 → '150,000'
  static String formatNumber(int amount) {
    return _vndFormat.format(amount);
  }

  // Phân tích chuỗi VND đã định dạng về số nguyên.
  // Loại bỏ các ký tự không phải chữ số. Trả về null nếu thất bại.
  static int? parse(String text) {
    final digits = text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }
}
