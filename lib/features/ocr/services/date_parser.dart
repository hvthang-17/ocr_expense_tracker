import 'package:ocr_expense_tracker/core/utils/date_formatter.dart';

// Bộ phân tích ngày giao dịch từ văn bản OCR của biên lai.
class DateParser {
  // Regex ngày theo định dạng DD/MM/YYYY, DD-MM-YYYY, DD.MM.YYYY
  static final RegExp _ddmmyyyyRegex = RegExp(
    r'\b(0?[1-9]|[12][0-9]|3[01])[/.-](0?[1-9]|1[0-2])[/.-]((?:19|20)\d{2})\b',
  );

  // Regex ngày theo định dạng YYYY-MM-DD, YYYY/MM/DD, YYYY.MM.DD
  static final RegExp _yyyymmddRegex = RegExp(
    r'\b((?:19|20)\d{2})[/.-](0?[1-9]|1[0-2])[/.-](0?[1-9]|[12][0-9]|3[01])\b',
  );

  // Regex ngày với năm 2 chữ số DD/MM/YY, DD-MM-YY
  static final RegExp _ddmmyyRegex = RegExp(
    r'\b(0?[1-9]|[12][0-9]|3[01])[/.-](0?[1-9]|1[0-2])[/.-](\d{2})\b',
  );

  // Regex phát hiện ngày dạng chữ tiếng Việt: "Ngày 15 tháng 10 năm 2024", "16 thg 3, 2022", "16 thg 03, 2022", "16 thg. 3, 2022"
  static final RegExp _vietnameseDateRegex = RegExp(
    r'(?:ng[aà]y\s*)?(0?[1-9]|[12][0-9]|3[01])\s*(?:th[aá]ng|thg\.?|\/|-)\s*(0?[1-9]|1[0-2])\s*(?:n[aă]m|[\/,.-])?\s*((?:19|20)?\d{2})\b',
    caseSensitive: false,
  );

  // Các từ khóa chỉ dòng chứa ngày tháng
  static final List<String> _dateKeywords = [
    'ngày',
    'ngay',
    'date',
    'thời gian',
    'thoi gian',
    'tg:',
    'time',
    'thg',
    'tháng',
  ];

  // Phân tích văn bản OCR và trả về ngày ISO-8601 'YYYY-MM-DD' hợp lệ.
  static String? parse(String rawText) {
    if (rawText.trim().isEmpty) return null;

    final lines = rawText.split('\n').map((l) => l.trim()).toList();

    // 1. Ưu tiên tìm ngày trên các dòng có chứa từ khóa ngày tháng
    for (final line in lines) {
      final lineLower = line.toLowerCase();
      final hasKeyword = _dateKeywords.any((kw) => lineLower.contains(kw));
      if (hasKeyword) {
        final parsedDate = _extractDateFromLine(line);
        if (parsedDate != null) return parsedDate;
      }
    }

    // 2. Tìm ngày trên tất cả các dòng còn lại
    for (final line in lines) {
      final parsedDate = _extractDateFromLine(line);
      if (parsedDate != null) return parsedDate;
    }

    return null;
  }

  // Trích xuất ngày từ một dòng văn bản đơn lẻ.
  static String? _extractDateFromLine(String line) {
    final result = _parseLine(line);
    if (result != null) return result;

    // Thử sửa các ký tự OCR dễ nhầm trong chữ số (O/o->0, l/I->1, S/s->5, B->8, Z/z->2, q/Q->9)
    final cleanedLine = line
        .replaceAll(RegExp(r'[Oo]'), '0')
        .replaceAll(RegExp(r'[Il|]'), '1')
        .replaceAll(RegExp(r'[Ss]'), '5')
        .replaceAll(RegExp(r'[Bb]'), '8')
        .replaceAll(RegExp(r'[Zz]'), '2')
        .replaceAll(RegExp(r'[qQ]'), '9');
    return _parseLine(cleanedLine);
  }

  static String? _parseLine(String line) {
    // 1. Thử khớp DD/MM/YYYY
    final ddmmyyyyMatches = _ddmmyyyyRegex.allMatches(line);
    for (final match in ddmmyyyyMatches) {
      final day = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      final year = int.parse(match.group(3)!);
      final iso = _validateAndFormatDate(year, month, day);
      if (iso != null) return iso;
    }

    // 2. Thử khớp YYYY-MM-DD
    final yyyymmddMatches = _yyyymmddRegex.allMatches(line);
    for (final match in yyyymmddMatches) {
      final year = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      final day = int.parse(match.group(3)!);
      final iso = _validateAndFormatDate(year, month, day);
      if (iso != null) return iso;
    }

    // 3. Thử khớp tiếng Việt: "Ngày 15 tháng 10 năm 2024", "16 thg 3, 2022", "16 thg. 03, 2022"
    final vnMatches = _vietnameseDateRegex.allMatches(line);
    for (final match in vnMatches) {
      final day = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      var rawYear = int.parse(match.group(3)!);
      if (rawYear < 100) {
        rawYear = rawYear <= 69 ? 2000 + rawYear : 1900 + rawYear;
      }
      final iso = _validateAndFormatDate(rawYear, month, day);
      if (iso != null) return iso;
    }

    // 4. Thử khớp DD/MM/YY (năm 2 chữ số)
    final ddmmyyMatches = _ddmmyyRegex.allMatches(line);
    for (final match in ddmmyyMatches) {
      final day = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      final rawYear = int.parse(match.group(3)!);
      final year = rawYear <= 69 ? 2000 + rawYear : 1900 + rawYear;
      final iso = _validateAndFormatDate(year, month, day);
      if (iso != null) return iso;
    }

    return null;
  }

  // Kiểm tra tính hợp lệ của ngày tháng và định dạng về YYYY-MM-DD.
  static String? _validateAndFormatDate(int year, int month, int day) {
    if (year < 1990 || year > 2100) return null;
    if (month < 1 || month > 12) return null;
    if (day < 1 || day > 31) return null;

    try {
      final dt = DateTime(year, month, day);
      if (dt.year == year && dt.month == month && dt.day == day) {
        return DateFormatter.toIso(dt);
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}