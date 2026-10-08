import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';

// Kết quả phân tích văn bản OCR từ biên lai.
class ParsedReceipt {
  // Tên cửa hàng / đơn vị bán (có thể null nếu không nhận diện được).
  final String? merchant;

  // Ngày giao dịch theo định dạng ISO-8601 'YYYY-MM-DD' (có thể null).
  final String? date;

  // Tổng tiền VND dạng số nguyên (có thể null).
  final int? totalAmount;

  // Danh mục chi tiêu được gợi ý (có thể null).
  final ExpenseCategory? category;

  // Văn bản thô từ OCR dùng để phân tích.
  final String rawText;

  // Đường dẫn file ảnh biên lai đã cắt / xử lý.
  final String? imagePath;

  const ParsedReceipt({
    this.merchant,
    this.date,
    this.totalAmount,
    this.category,
    required this.rawText,
    this.imagePath,
  });

  // Kiểm tra xem tất cả trường chính đã được trích xuất thành công chưa.
  bool get isComplete =>
      merchant != null &&
      merchant!.isNotEmpty &&
      date != null &&
      totalAmount != null;

  // Tạo bản sao với các thuộc tính thay đổi.
  ParsedReceipt copyWith({
    String? merchant,
    String? date,
    int? totalAmount,
    ExpenseCategory? category,
    String? rawText,
    String? imagePath,
  }) {
    return ParsedReceipt(
      merchant: merchant ?? this.merchant,
      date: date ?? this.date,
      totalAmount: totalAmount ?? this.totalAmount,
      category: category ?? this.category,
      rawText: rawText ?? this.rawText,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  String toString() {
    return 'ParsedReceipt(merchant: $merchant, date: $date, '
        'amount: $totalAmount, category: ${category?.name}, imagePath: $imagePath, complete: $isComplete)';
  }
}

