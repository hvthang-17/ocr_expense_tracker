import 'package:intl/intl.dart';

// Lớp tiện ích định dạng và phân tích ngày tháng.
class DateFormatter {
  DateFormatter._();

  // Định dạng ISO-8601 chỉ ngày — dùng để lưu vào cơ sở dữ liệu.
  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');

  // Định dạng hiển thị cho người dùng Việt Nam.
  static final DateFormat _displayFormat = DateFormat('dd/MM/yyyy');

  // Chuyển DateTime sang chuỗi ISO-8601 chỉ ngày để lưu trữ.
  // Ví dụ: DateTime(2026, 9, 12) → '2026-09-12'
  static String toIso(DateTime date) {
    return _isoFormat.format(date);
  }

  // Chuyển DateTime sang chuỗi hiển thị.
  // Ví dụ: DateTime(2026, 9, 12) → '12/09/2026'
  static String toDisplay(DateTime date) {
    return _displayFormat.format(date);
  }

  // Phân tích chuỗi ISO-8601 chỉ ngày thành DateTime.
  // Trả về null nếu phân tích thất bại.
  static DateTime? fromIso(String isoString) {
    try {
      return _isoFormat.parseStrict(isoString);
    } catch (_) {
      return null;
    }
  }

  // Phân tích chuỗi ngày ISO-8601 hoặc dd/MM/yyyy thành DateTime.
  // Trả về null nếu phân tích thất bại.
  static DateTime? parse(String text) {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return null;
    final isoDate = fromIso(cleaned);
    if (isoDate != null) return isoDate;
    final tryIso = DateTime.tryParse(cleaned);
    if (tryIso != null) return tryIso;
    try {
      return _displayFormat.parseStrict(cleaned);
    } catch (_) {
      try {
        return DateFormat('d/M/yyyy').parseStrict(cleaned);
      } catch (_) {
        return null;
      }
    }
  }

  // Chuyển chuỗi ngày ISO-8601 sang định dạng hiển thị.
  // Trả về chuỗi gốc nếu phân tích thất bại.
  static String isoToDisplay(String isoString) {
    final date = fromIso(isoString);
    if (date == null) return isoString;
    return toDisplay(date);
  }
}
