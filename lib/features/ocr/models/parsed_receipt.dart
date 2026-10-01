// Kết quả phân tích văn bản OCR từ biên lai.
class ParsedReceipt {
  // Tên cửa hàng / đơn vị bán (có thể null nếu không nhận diện được).
  final String? merchant;

  // Ngày giao dịch theo định dạng ISO-8601 'YYYY-MM-DD' (có thể null).
  final String? date;

  // Tổng tiền VND dạng số nguyên (có thể null).
  final int? totalAmount;

  // Văn bản thô từ OCR dùng để phân tích.
  final String rawText;

  const ParsedReceipt({
    this.merchant,
    this.date,
    this.totalAmount,
    required this.rawText,
  });

  // Kiểm tra xem tất cả trường chính đã được trích xuất thành công chưa.
  bool get isComplete =>
      merchant != null &&
      merchant!.isNotEmpty &&
      date != null &&
      totalAmount != null;

  @override
  String toString() {
    return 'ParsedReceipt(merchant: $merchant, date: $date, '
        'amount: $totalAmount, complete: $isComplete)';
  }
}
