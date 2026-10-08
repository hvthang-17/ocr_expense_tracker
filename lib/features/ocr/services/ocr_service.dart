import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'package:ocr_expense_tracker/features/ocr/models/parsed_receipt.dart';
import 'package:ocr_expense_tracker/features/ocr/services/receipt_parser_service.dart';

// Dịch vụ OCR sử dụng Google ML Kit Text Recognition (on-device).
//
// Pipeline:
// 1. Nhận đường dẫn file ảnh đã crop/nén.
// 2. Tạo [InputImage] từ file path.
// 3. Chạy [TextRecognizer.processImage] để nhận dạng văn bản.
// 4. Ghép [TextBlock] → [TextLine] thành raw text string.
// 5. Truyền raw text cho [ReceiptParserService.parse] để trích xuất thông tin.
// 6. Đóng [TextRecognizer] để giải phóng tài nguyên.
class OcrService {
  OcrService._();

  // Nhận dạng văn bản từ ảnh và phân tích thành [ParsedReceipt].
  //
  // [imagePath]: Đường dẫn file ảnh đã crop/nén từ [ImageProcessingService].
  //
  // Trả về [ParsedReceipt] chứa merchant, date, amount, category và rawText.
  // Trả về `null` nếu OCR thất bại hoặc không nhận diện được văn bản.
  static Future<ParsedReceipt?> recognizeAndParse(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await recognizer.processImage(inputImage);

      final rawText = extractText(recognizedText);

      if (rawText.trim().isEmpty) {
        debugPrint('OcrService: Không nhận dạng được văn bản từ ảnh.');
        return const ParsedReceipt(rawText: '');
      }

      debugPrint('OcrService: Đã nhận dạng ${recognizedText.blocks.length} '
          'block, raw text ${rawText.length} ký tự.');

      return ReceiptParserService.parse(rawText);
    } catch (e) {
      debugPrint('OcrService error: $e');
      return null;
    } finally {
      await recognizer.close();
    }
  }

  // Ghép [RecognizedText] thành chuỗi raw text.
  //
  // Duyệt qua từng [TextBlock], mỗi block chứa nhiều [TextLine].
  // Mỗi line được nối bằng ký tự xuống dòng `\n`.
  // Giữa các block cũng ngăn cách bằng `\n` để phản ánh bố cục thực tế
  // của biên lai (tiêu đề, dòng sản phẩm, tổng tiền...).
  @visibleForTesting
  static String extractText(RecognizedText recognizedText) {
    final buffer = StringBuffer();

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        buffer.writeln(line.text);
      }
    }

    return buffer.toString().trimRight();
  }
}
