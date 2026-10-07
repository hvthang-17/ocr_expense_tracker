import 'package:ocr_expense_tracker/features/ocr/models/parsed_receipt.dart';
import 'package:ocr_expense_tracker/features/ocr/services/amount_parser.dart';
import 'package:ocr_expense_tracker/features/ocr/services/category_suggestion_service.dart';
import 'package:ocr_expense_tracker/features/ocr/services/date_parser.dart';
import 'package:ocr_expense_tracker/features/ocr/services/merchant_parser.dart';

// Dịch vụ chính hợp nhất quy trình phân tích biên lai từ văn bản OCR thô.
class ReceiptParserService {
  // Phân tích văn bản OCR thô và trả về ParsedReceipt chứa các thông tin trích xuất.
  static ParsedReceipt parse(String rawText) {
    final merchant = MerchantParser.parse(rawText);
    final date = DateParser.parse(rawText);
    final totalAmount = AmountParser.parse(rawText);
    final category = CategorySuggestionService.suggestCategory(
      merchant: merchant,
      rawText: rawText,
    );

    return ParsedReceipt(
      merchant: merchant,
      date: date,
      totalAmount: totalAmount,
      category: category,
      rawText: rawText,
    );
  }
}