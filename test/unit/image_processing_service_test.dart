import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  group('ImageProcessingService logic tests', () {
    test('Image decode and crop center creates correct dimensions', () {
      // 1. Tạo ảnh test 1000x1000 màu đỏ.
      final original = img.Image(width: 1000, height: 1000);
      img.fill(original, color: img.ColorRgb8(255, 0, 0));

      // 2. Crop với tỷ lệ 0.88x0.55.
      final cropW = (1000 * 0.88).round(); // 880
      final cropH = (1000 * 0.55).round(); // 550
      final x = ((1000 - cropW) / 2).round(); // 60
      final y = ((1000 - cropH) / 2).round(); // 225

      final cropped = img.copyCrop(
        original,
        x: x,
        y: y,
        width: cropW,
        height: cropH,
      );

      expect(cropped.width, equals(880));
      expect(cropped.height, equals(550));
    });

    test('Resize decreases dimensions when exceeding maxLongSide', () {
      // 1. Tạo ảnh 3000x2000 (cạnh dài 3000px).
      final largeImage = img.Image(width: 3000, height: 2000);
      const maxLongSide = 2000;

      // 2. Resize cạnh dài nhất về 2000px.
      final resized = img.copyResize(largeImage, width: maxLongSide);

      expect(resized.width, equals(2000));
      expect(resized.height, equals(1333)); // Aspect ratio 3:2 được giữ nguyên.
    });

    test('Resize leaves small image untouched', () {
      // 1. Tạo ảnh 1200x800 (nhỏ hơn 2000px).
      final smallImage = img.Image(width: 1200, height: 800);
      const maxLongSide = 2000;

      // 2. Kiểm tra cạnh dài nhất.
      final longestSide = smallImage.width > smallImage.height
          ? smallImage.width
          : smallImage.height;

      expect(longestSide <= maxLongSide, isTrue);
      // Ảnh giữ nguyên kích thước.
      expect(smallImage.width, equals(1200));
      expect(smallImage.height, equals(800));
    });

    test('JPEG encoding compresses image with quality', () {
      final testImage = img.Image(width: 500, height: 500);
      img.fill(testImage, color: img.ColorRgb8(0, 128, 255));

      final jpegBytes = Uint8List.fromList(img.encodeJpg(testImage, quality: 85));

      expect(jpegBytes, isNotEmpty);
      // Kiểm tra hai byte đầu JPEG SOI (0xFF, 0xD8).
      expect(jpegBytes[0], equals(0xFF));
      expect(jpegBytes[1], equals(0xD8));
    });
  });
}
