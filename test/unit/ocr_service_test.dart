import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:ocr_expense_tracker/features/ocr/services/ocr_service.dart';

void main() {
  group('OcrService extractText Unit Tests', () {
    test('extractText converts RecognizedText blocks and lines into raw string', () {
      final line1 = TextLine(
        text: 'HIGHLANDS COFFEE',
        elements: const [],
        boundingBox: Rect.zero,
        recognizedLanguages: const [],
        cornerPoints: const [],
        confidence: 0.99,
        angle: 0.0,
      );

      final line2 = TextLine(
        text: 'Ngày: 15/10/2024',
        elements: const [],
        boundingBox: Rect.zero,
        recognizedLanguages: const [],
        cornerPoints: const [],
        confidence: 0.99,
        angle: 0.0,
      );

      final line3 = TextLine(
        text: 'TỔNG CỘNG: 65.000 VND',
        elements: const [],
        boundingBox: Rect.zero,
        recognizedLanguages: const [],
        cornerPoints: const [],
        confidence: 0.99,
        angle: 0.0,
      );

      final block1 = TextBlock(
        text: 'HIGHLANDS COFFEE\nNgày: 15/10/2024',
        lines: [line1, line2],
        boundingBox: Rect.zero,
        recognizedLanguages: const [],
        cornerPoints: const [],
      );

      final block2 = TextBlock(
        text: 'TỔNG CỘNG: 65.000 VND',
        lines: [line3],
        boundingBox: Rect.zero,
        recognizedLanguages: const [],
        cornerPoints: const [],
      );

      final recognizedText = RecognizedText(
        text: 'HIGHLANDS COFFEE\nNgày: 15/10/2024\nTỔNG CỘNG: 65.000 VND',
        blocks: [block1, block2],
      );

      final rawText = OcrService.extractText(recognizedText);

      expect(rawText, contains('HIGHLANDS COFFEE'));
      expect(rawText, contains('Ngày: 15/10/2024'));
      expect(rawText, contains('TỔNG CỘNG: 65.000 VND'));
    });

    test('extractText with empty blocks returns empty string', () {
      final recognizedText = RecognizedText(text: '', blocks: const []);
      final rawText = OcrService.extractText(recognizedText);
      expect(rawText, isEmpty);
    });
  });
}

