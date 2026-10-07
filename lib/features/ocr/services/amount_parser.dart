import 'package:ocr_expense_tracker/core/utils/currency_formatter.dart';

// Bộ phân tích tổng số tiền từ văn bản OCR của biên lai.
class AmountParser {
  // Các từ khóa chỉ dòng chứa tổng tiền.
  static final List<String> _explicitTotalKeywords = [
    'tổng cộng',
    'tong cong',
    'tổng tiền',
    'tong tien',
    'thành tiền',
    'thanh tien',
    'tổng thanh toán',
    'tong thanh toan',
    'cần thanh toán',
    'can thanh toan',
    'cước phí',
    'cuoc phi',
    'tổng',
    'tong',
    'cộng',
    'cong',
    'số tiền',
    'so tien',
    'tiền mặt',
    'tien mat',
    'grand total',
    'total due',
    'amount due',
    'total',
    'sum',
    'amount',
    'paid',
  ];

  // Regex trích xuất số có chứa phân cách ngàn/thập phân và đơn vị tiền tệ.
  static final RegExp _amountRegex = RegExp(
    r'(?:VND|VNĐ|đ|Đ|\$)?\s*(\d{1,3}(?:[.,\s]\d{3})+(?:[.,]\d{1,2})?|\d{4,9})\s*(?:VND|VNĐ|đ|Đ|\$)?',
    caseSensitive: false,
  );

  // Regex phát hiện định dạng ngày để tránh nhầm lẫn ngày (ví dụ: 2024-07-18) với số tiền.
  static final RegExp _dateLineRegex = RegExp(
    r'\b(?:\d{1,4}[/.-]\d{1,2}[/.-]\d{1,4})\b',
  );

  // Regex phát hiện dòng số điện thoại hoặc mã số thuế.
  static final RegExp _telOrTaxRegex = RegExp(
    r'(?:sđt|sdt|tel|phone|hotline|mst| tax|0[35789]\d{8}|1[89]00)\b',
    caseSensitive: false,
  );

  // Phân tích văn bản thô OCR và trả về tổng tiền dạng số nguyên VND.
  static int? parse(String rawText) {
    if (rawText.trim().isEmpty) return null;

    final lines = rawText.split('\n').map((l) => l.trim()).toList();

    // 1. Tìm các dòng chứa từ khóa chỉ tổng tiền trực tiếp
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineLower = line.toLowerCase();

      final hasKeyword = _explicitTotalKeywords.any((kw) => lineLower.contains(kw));
      if (hasKeyword) {
        // Thử tìm số tiền trên chính dòng này
        final amountInLine = _extractAmountFromText(line);
        if (amountInLine != null && _isValidVndAmount(amountInLine)) {
          return amountInLine;
        }

        // Nếu dòng hiện tại không có số tiền, thử tìm ở dòng tiếp theo (nếu dòng đó không phải ngày tháng/sđt)
        if (i + 1 < lines.length) {
          final nextLine = lines[i + 1];
          if (!_dateLineRegex.hasMatch(nextLine) && !_telOrTaxRegex.hasMatch(nextLine)) {
            final nextLineAmount = _extractAmountFromText(nextLine);
            if (nextLineAmount != null && _isValidVndAmount(nextLineAmount)) {
              return nextLineAmount;
            }
          }
        }
      }
    }

    // 2. Nếu không tìm thấy dòng từ khóa, tìm các dòng có ký hiệu tiền tệ (VND, đ, VNĐ)
    for (final line in lines) {
      final lineLower = line.toLowerCase();
      if ((lineLower.contains('vnd') ||
              lineLower.contains('vnđ') ||
              lineLower.contains('đ')) &&
          !_dateLineRegex.hasMatch(line) &&
          !_telOrTaxRegex.hasMatch(line)) {
        final amount = _extractAmountFromText(line);
        if (amount != null && _isValidVndAmount(amount)) {
          return amount;
        }
      }
    }

    // 3. Dự phòng: tìm số có giá trị phù hợp lớn nhất trên toàn bộ văn bản
    final candidateAmounts = <int>[];
    for (final line in lines) {
      final lineLower = line.toLowerCase();
      // Bỏ qua dòng số điện thoại, mã số thuế, ngày tháng
      if (_telOrTaxRegex.hasMatch(lineLower) || _dateLineRegex.hasMatch(line)) {
        continue;
      }

      final matches = _amountRegex.allMatches(line);
      for (final match in matches) {
        final rawNum = match.group(1) ?? match.group(0);
        if (rawNum != null) {
          final parsed = CurrencyFormatter.parse(rawNum);
          if (parsed != null && _isValidVndAmount(parsed)) {
            candidateAmounts.add(parsed);
          }
        }
      }
    }

    if (candidateAmounts.isNotEmpty) {
      candidateAmounts.sort();
      return candidateAmounts.last;
    }

    return null;
  }

  // Trích xuất và chuyển đổi chuỗi chứa số thành số nguyên VND.
  static int? _extractAmountFromText(String text) {
    final matches = _amountRegex.allMatches(text);
    for (final match in matches) {
      final matchedText = match.group(1) ?? match.group(0);
      if (matchedText != null) {
        final parsed = CurrencyFormatter.parse(matchedText);
        if (parsed != null && _isValidVndAmount(parsed)) {
          return parsed;
        }
      }
    }
    return null;
  }

  // Kiểm tra số tiền VND hợp lệ (từ 500đ đến 1,000,000,000đ).
  static bool _isValidVndAmount(int amount) {
    return amount >= 500 && amount <= 1000000000;
  }
}