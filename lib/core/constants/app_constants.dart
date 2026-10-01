// Các hằng số toàn cục của ứng dụng.
class AppConstants {
  AppConstants._();

  // Tên ứng dụng hiển thị trên giao diện.
  static const String appName = 'OCR Expense Tracker';

  // Tên file cơ sở dữ liệu SQLite.
  static const String databaseName = 'expense_tracker.db';

  // Phiên bản cơ sở dữ liệu — tăng khi thay đổi schema.
  static const int databaseVersion = 1;

  // Thư mục con trong app documents để lưu ảnh biên lai thu nhỏ.
  static const String receiptImageDir = 'receipts';

  // Chất lượng nén JPEG cho ảnh biên lai đã lưu (0–100).
  static const int jpegQuality = 85;

  // Chiều dài pixel tối đa của cạnh dài nhất sau khi resize.
  static const int maxImageLongSide = 2000;

  // Ký hiệu tiền tệ dùng để hiển thị.
  static const String currencySymbol = 'VND';

  // Số tuần gần nhất hiển thị trên biểu đồ cột.
  static const int barChartWeeks = 5;
}
