import 'package:ocr_expense_tracker/core/utils/currency_formatter.dart';
import 'package:ocr_expense_tracker/features/ocr/services/ocr_text_cleaner.dart';

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
    'thanh toán',
    'thanh toan',
    'tổng tiền hàng',
    'tong tien hang',
    'tổng chi phí',
    'tong chi phi',
    'tổng trả',
    'tong tra',
    'tiền cộng',
    'cước phí',
    'cuoc phi',
    'tổng net',
    'tong net',
    'khách trả',
    'khach tra',
    'tổng',
    'tong',
    'cộng',
    'cong',
    'số tiền',
    'so tien',
    'tiền mặt',
    'tien mat',
    'chuyển khoản',
    'chuyen khoan',
    'grand total',
    'total due',
    'amount due',
    'net total',
    'total amount',
    'balance due',
    'subtotal',
    'total',
    'sum',
    'amount',
    'paid',
    't.cộng',
    't.cong',
    't.toán',
    't.toan',
    'tt:',
  ];

  // Các từ khóa chỉ dòng tiền thừa, giảm giá (cần bỏ qua khi tính toán tổng tiền chính)
  static final List<String> _ignoreKeywords = [
    'tiền thừa',
    'tien thua',
    'tiền thối',
    'tien thoi',
    'change',
    'discount',
    'giảm giá',
    'giam gia',
    'khuyến mãi',
    'khuyen mai',
    'voucher',
    'điểm tích lũy',
  ];

  // Regex trích xuất số có chứa phân cách ngàn/thập phân và đơn vị tiền tệ.
  static final RegExp _amountRegex = RegExp(
    r'(?:VND|VNĐ|đ|Đ|d|\$)?\s*'
    r'(\d{1,3}(?:[.,\s]\d{3})+(?:[.,]\d{1,2})?|\d{4,9})'
    r'\s*(?:VND|VNĐ|đ|Đ|d|\$)?',
    caseSensitive: false,
  );

  // Regex mở rộng: phát hiện cụm số có ký tự OCR sai (O, l, S, B, Z, Q).
  static final RegExp _fuzzyAmountRegex = RegExp(
    r'(?:VND|VNĐ|đ|Đ|d|\$)?\s*'
    r'([\dOoIlSsBbZzqQg]{1,3}(?:[.,\s][\dOoIlSsBbZzqQg]{3})+|[\dOoIlSsBbZzqQg]{4,9})'
    r'\s*(?:VND|VNĐ|đ|Đ|d|\$)?',
    caseSensitive: false,
  );

  // Regex phát hiện định dạng ngày.
  static final RegExp _dateLineRegex = RegExp(
    r'\b(?:\d{1,4}[/.-]\d{1,2}[/.-]\d{1,4})\b',
  );

  // Regex phát hiện dòng số điện thoại, mã số thuế hoặc mã hóa đơn.
  static final RegExp _telOrTaxRegex = RegExp(
    r'(?:sđt|sdt|tel|phone|hotline|mst|tax|hd\d+|invoice|0[35789]\d{8}|1[89]00)\b',
    caseSensitive: false,
  );

  // Regex phát hiện dòng item/sản phẩm.
  static final RegExp _itemLineRegex = RegExp(r'^\d+\s*[xX×]\s');

  // Phân tích văn bản thô OCR và trả về tổng tiền dạng số nguyên VND.
  static int? parse(String rawText) {
    if (rawText.trim().isEmpty) return null;

    // Chuẩn hóa khoảng trắng giữa các chữ số trước khi phân tích.
    final normalizedText = OcrTextCleaner.normalizeSpacedDigits(rawText);
    final lines = normalizedText.split('\n').map((l) => l.trim()).toList();

    // 1. Tìm các dòng chứa từ khóa chỉ tổng tiền trực tiếp
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineLower = line.toLowerCase();

      // Nếu dòng chứa từ khóa bị bỏ qua (tiền thừa / giảm giá) -> bỏ qua
      if (_ignoreKeywords.any((kw) => lineLower.contains(kw))) {
        continue;
      }

      final hasKeyword = _explicitTotalKeywords.any((kw) => lineLower.contains(kw));
      if (hasKeyword) {
        // Thử tìm số tiền trên chính dòng này
        final amountInLine = _extractAmountFromText(line);
        if (amountInLine != null && _isValidVndAmount(amountInLine)) {
          return amountInLine;
        }
        // Thử regex mờ (fuzzy) cho dòng có từ khóa
        final fuzzyAmount = _extractFuzzyAmountFromText(line);
        if (fuzzyAmount != null && _isValidVndAmount(fuzzyAmount)) {
          return fuzzyAmount;
        }

        // Nếu dòng hiện tại không có số tiền, thử dòng tiếp theo
        if (i + 1 < lines.length) {
          final nextLine = lines[i + 1];
          if (!_dateLineRegex.hasMatch(nextLine) &&
              !_telOrTaxRegex.hasMatch(nextLine)) {
            final nextAmount = _extractAmountFromText(nextLine) ??
                _extractFuzzyAmountFromText(nextLine);
            if (nextAmount != null && _isValidVndAmount(nextAmount)) {
              return nextAmount;
            }
          }
        }
      }
    }

    // 2. Tìm dòng có ký hiệu tiền tệ (VND, đ, VNĐ)
    for (final line in lines) {
      final lineLower = line.toLowerCase();
      if ((lineLower.contains('vnd') ||
              lineLower.contains('vnđ') ||
              lineLower.contains('đ')) &&
          !_dateLineRegex.hasMatch(line) &&
          !_telOrTaxRegex.hasMatch(line)) {
        final amount = _extractAmountFromText(line) ??
            _extractFuzzyAmountFromText(line);
        if (amount != null && _isValidVndAmount(amount)) {
          return amount;
        }
      }
    }

    // 3. Dự phòng: tìm số có giá trị phù hợp lớn nhất
    final candidateAmounts = <int>[];
    for (final line in lines) {
      final lineLower = line.toLowerCase();
      if (_telOrTaxRegex.hasMatch(lineLower) ||
          _dateLineRegex.hasMatch(line)) {
        continue;
      }
      if (lines.length > 3 && _itemLineRegex.hasMatch(line)) continue;

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

  // Trích xuất số tiền từ text có ký tự OCR sai (O→0, l→1...).
  static int? _extractFuzzyAmountFromText(String text) {
    final matches = _fuzzyAmountRegex.allMatches(text);
    for (final match in matches) {
      var matchedText = match.group(1) ?? match.group(0);
      if (matchedText != null) {
        // Sửa ký tự OCR sai thành chữ số
        matchedText = matchedText
            .replaceAll(RegExp(r'[Oo]'), '0')
            .replaceAll(RegExp(r'[Il|]'), '1')
            .replaceAll(RegExp(r'[Ss]'), '5')
            .replaceAll(RegExp(r'[Bb]'), '8');
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