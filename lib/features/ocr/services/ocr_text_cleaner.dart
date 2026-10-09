// Bộ hậu xử lý văn bản OCR — sửa lỗi nhận dạng phổ biến trên biên lai nhiệt Việt Nam.
//
// Google ML Kit thường nhận dạng sai các ký tự khi chụp biên lai thật:
// - Số `0` → chữ `O`, `o`
// - Số `1` → chữ `l`, `I`, `|`
// - Số `5` → chữ `S`, `s`
// - Số `8` → chữ `B`
// - Số `2` → chữ `Z`, `z`
// - Số `9` → chữ `q`, `Q`, `g`
// - Dấu chấm `.` / phẩy `,` có khoảng trắng thừa
// - Khoảng trắng thừa giữa các nhóm chữ số nghìn
//
// Bộ cleaner này xử lý trong **ngữ cảnh số tiền và ngày tháng**,
// không làm hỏng chữ thường hay tên cửa hàng.
class OcrTextCleaner {
  OcrTextCleaner._();

  // Regex phát hiện vùng "giống số tiền" (chữ số + ký tự thường bị nhận sai + dấu phân cách).
  static final RegExp _moneyLikeRegex = RegExp(
    r'[\dOoIlSsBbZzqQg]{1,3}(?:[.,\s][\dOoIlSsBbZzqQg]{3})+(?:\s*(?:VND|VNĐ|đ|Đ|d|\$))?'
    r'|[\dOoIlSsBbZzqQg]{4,9}(?:\s*(?:VND|VNĐ|đ|Đ|d|\$))?',
    caseSensitive: false,
  );

  // Regex phát hiện vùng "giống ngày tháng" (DD/MM/YYYY, YYYY-MM-DD, v.v.).
  static final RegExp _dateLikeRegex = RegExp(
    r'[\dOoIl]{1,4}[/.\-][\dOoIl]{1,2}[/.\-][\dOoIl]{2,4}',
  );

  // Regex phát hiện dòng chứa từ khóa tổng tiền.
  static final RegExp _totalKeywordRegex = RegExp(
    r'(?:t[oôổ][nng]+\s*(?:c[oộ][nng]+|ti[eề]n|thanh\s*to[aá]n)?|th[aà]nh\s*ti[eề]n|'
    r'c[uư][oớ]c\s*ph[ií]|total|amount|sum|paid|grand\s*total|subtotal)',
    caseSensitive: false,
  );

  // Sửa lỗi nhận dạng OCR trong toàn bộ raw text.
  static String clean(String rawText) {
    if (rawText.trim().isEmpty) return rawText;

    final lines = rawText.split('\n');
    final cleanedLines = <String>[];

    for (final line in lines) {
      var cleaned = line;

      // Chuẩn hóa khoảng trắng quanh dấu chấm/phẩy giữa các chữ số (ví dụ "150 . 000" -> "150.000")
      cleaned = cleaned.replaceAllMapped(
        RegExp(r'(\d)\s*([.,])\s*(\d)'),
        (match) => '${match.group(1)}${match.group(2)}${match.group(3)}',
      );

      // Sửa vùng giống số tiền
      cleaned = cleaned.replaceAllMapped(_moneyLikeRegex, (match) {
        return _fixDigits(match.group(0)!);
      });

      // Sửa vùng giống ngày tháng
      cleaned = cleaned.replaceAllMapped(_dateLikeRegex, (match) {
        return _fixDigits(match.group(0)!);
      });

      // Nếu dòng có từ khóa tổng tiền, sửa tất cả cụm số trong dòng
      if (_totalKeywordRegex.hasMatch(cleaned)) {
        cleaned = _fixDigitsInAmountLine(cleaned);
      }

      cleanedLines.add(cleaned);
    }

    return cleanedLines.join('\n');
  }

  // Sửa các ký tự bị nhận nhầm thành chữ số trong một cụm text đã được xác định là số/ngày.
  static String _fixDigits(String text) {
    return text
        .replaceAll(RegExp(r'[Oo]'), '0')
        .replaceAll(RegExp(r'[Il|iI]'), '1')
        .replaceAll(RegExp(r'[Ss]'), '5')
        .replaceAll(RegExp(r'[Bb]'), '8')
        .replaceAll(RegExp(r'[Zz]'), '2')
        .replaceAll(RegExp(r'[qQ]'), '9');
  }

  // Sửa tất cả cụm số trong dòng chứa từ khóa tổng tiền.
  static String _fixDigitsInAmountLine(String line) {
    return line.replaceAllMapped(
      RegExp(r'[\dOoIlSsBbZzqQg]{1,3}(?:[.,\s][\dOoIlSsBbZzqQg]{3})+|[\dOoIlSsBbZzqQg]{4,9}'),
      (match) => _fixDigits(match.group(0)!),
    );
  }

  // Chuẩn hóa khoảng trắng thừa giữa các chữ số (ví dụ: "65 000" → "65.000").
  static String normalizeSpacedDigits(String text) {
    return text.replaceAllMapped(
      RegExp(r'(\d{1,3})(?:\s+(\d{3}))+(?=\s|$|[đĐ]|VN[DĐ]|\$)'),
      (match) {
        final parts = match.group(0)!.trim().split(RegExp(r'\s+'));
        return parts.join('.');
      },
    );
  }
}
