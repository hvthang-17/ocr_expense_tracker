import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'package:ocr_expense_tracker/features/ocr/models/parsed_receipt.dart';
import 'package:ocr_expense_tracker/features/ocr/services/ocr_text_cleaner.dart';
import 'package:ocr_expense_tracker/features/ocr/services/receipt_parser_service.dart';

// Dịch vụ OCR sử dụng Google ML Kit Text Recognition (on-device).
//
// Pipeline:
// 1. Nhận đường dẫn file ảnh đã crop/nén.
// 2. Tạo InputImage từ file path.
// 3. Chạy TextRecognizer.processImage để nhận dạng văn bản.
// 4. Sắp xếp TextBlock theo tọa độ Y (trên xuống dưới).
// 5. Ghép TextBlock thành raw text string.
// 6. Chạy OcrTextCleaner.clean để sửa lỗi nhận dạng phổ biến.
// 7. Truyền raw text cho ReceiptParserService.parse để trích xuất thông tin.
// 8. Đóng TextRecognizer để giải phóng tài nguyên.
class OcrService {
  OcrService._();

  // Nhận dạng văn bản từ ảnh và phân tích thành ParsedReceipt.
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
      debugPrint('OcrService raw:\n$rawText');

      // Hậu xử lý: sửa lỗi nhận dạng phổ biến (O→0, l→1, S→5...).
      final cleanedText = OcrTextCleaner.clean(rawText);

      if (cleanedText != rawText) {
        debugPrint('OcrService cleaned:\n$cleanedText');
      }

      return ReceiptParserService.parse(cleanedText);
    } catch (e) {
      debugPrint('OcrService error: $e');
      return null;
    } finally {
      await recognizer.close();
    }
  }

  // Ghép RecognizedText thành chuỗi raw text.
  //
  // Sắp xếp các TextBlock theo tọa độ Y (top) từ trên xuống dưới
  // để phản ánh đúng thứ tự đọc thực tế trên biên lai.
  @visibleForTesting
  static String extractText(RecognizedText recognizedText) {
    final buffer = StringBuffer();

    // Sắp xếp blocks theo tọa độ Y (top → bottom).
    final sortedBlocks = List<TextBlock>.from(recognizedText.blocks)
      ..sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

    for (final block in sortedBlocks) {
      for (final line in block.lines) {
        buffer.writeln(line.text);
      }
    }

    return buffer.toString().trimRight();
  }
}
