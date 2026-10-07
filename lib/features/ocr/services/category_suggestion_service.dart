import 'package:ocr_expense_tracker/core/constants/category_keywords.dart';
import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';

// Dịch vụ gợi ý danh mục chi tiêu dựa trên tên cửa hàng và nội dung OCR.
class CategorySuggestionService {
  // Gợi ý danh mục chi tiêu từ tên cửa hàng và/hoặc văn bản thô OCR.
  static ExpenseCategory suggestCategory({
    String? merchant,
    String? rawText,
  }) {
    // 1. Khớp từ khóa có dấu chính xác trên tên cửa hàng
    if (merchant != null && merchant.trim().isNotEmpty) {
      final merchantLower = merchant.toLowerCase();

      for (final entry in categoryKeywords.entries) {
        final keyword = entry.key.toLowerCase();
        if (_matchesWord(merchantLower, keyword)) {
          return entry.value;
        }
      }

      // 1b. Khớp không dấu trên tên cửa hàng
      final merchantUnaccented = _removeAccents(merchantLower);
      for (final entry in categoryKeywords.entries) {
        final keywordUnaccented = _removeAccents(entry.key.toLowerCase());
        if (_matchesWord(merchantUnaccented, keywordUnaccented)) {
          return entry.value;
        }
      }
    }

    // 2. Khớp từ khóa có dấu chính xác trên toàn bộ văn bản OCR
    if (rawText != null && rawText.trim().isNotEmpty) {
      final textLower = rawText.toLowerCase();

      for (final entry in categoryKeywords.entries) {
        final keyword = entry.key.toLowerCase();
        if (_matchesWord(textLower, keyword)) {
          return entry.value;
        }
      }

      // 2b. Khớp không dấu trên toàn bộ văn bản OCR
      final textUnaccented = _removeAccents(textLower);
      for (final entry in categoryKeywords.entries) {
        final keywordUnaccented = _removeAccents(entry.key.toLowerCase());
        if (_matchesWord(textUnaccented, keywordUnaccented)) {
          return entry.value;
        }
      }
    }

    // 3. Mặc định trả về danh mục Ăn uống (Food)
    return defaultCategory;
  }

  // Kiểm tra xem từ khóa có xuất hiện dưới dạng một từ riêng biệt hoặc ranh giới từ hợp lệ hay không.
  static bool _matchesWord(String text, String keyword) {
    if (keyword.length <= 3) {
      final pattern = RegExp(
        r'(?<=^|[^\w\p{L}])' + RegExp.escape(keyword) + r'(?=$|[^\w\p{L}])',
        unicode: true,
      );
      return pattern.hasMatch(text);
    }
    return text.contains(keyword);
  }

  // Loại bỏ dấu tiếng Việt để so sánh chuỗi không phân biệt có dấu / không dấu.
  static String _removeAccents(String text) {
    var result = text;
    const vietnameseMap = {
      'a': 'àáạảãâầấậẩẫăằắặẳẵ',
      'e': 'èéẹẻẽêềếệểễ',
      'i': 'ìíịỉĩ',
      'o': 'òóọỏõôồốộổỗơờớợởỡ',
      'u': 'ùúụủũưừứựửữ',
      'y': 'ỳýỵỷỹ',
      'd': 'đ',
    };

    for (final entry in vietnameseMap.entries) {
      for (final char in entry.value.split('')) {
        result = result.replaceAll(char, entry.key);
      }
    }
    return result;
  }
}