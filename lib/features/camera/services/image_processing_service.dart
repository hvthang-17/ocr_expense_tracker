import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:ocr_expense_tracker/core/constants/app_constants.dart';

// Dịch vụ xử lý ảnh biên lai: crop, resize, nén JPEG và lưu file.
//
// Quy trình xử lý:
// 1. Decode ảnh gốc từ file camera.
// 2. Crop theo vùng overlay (tỷ lệ truyền vào từ CropOverlayPainter).
// 3. Resize nếu cạnh dài > [AppConstants.maxImageLongSide] (2000px).
// 4. Encode JPEG với chất lượng [AppConstants.jpegQuality] (85%).
// 5. Lưu vào thư mục app documents / receipts / với tên duy nhất.
class ImageProcessingService {
  ImageProcessingService._();

  // Xử lý ảnh biên lai hoàn chỉnh: crop → resize → nén → lưu.
  //
  // [imagePath]: Đường dẫn file ảnh gốc từ camera.
  // [cropWidthRatio]: Tỷ lệ chiều rộng vùng crop (0.0–1.0).
  // [cropHeightRatio]: Tỷ lệ chiều cao vùng crop (0.0–1.0).
  //
  // Trả về đường dẫn file ảnh đã xử lý, hoặc `null` nếu thất bại.
  static Future<String?> processReceipt({
    required String imagePath,
    double cropWidthRatio = 0.88,
    double cropHeightRatio = 0.55,
  }) async {
    try {
      // Đọc file ảnh gốc.
      final file = File(imagePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();

      // Chạy decode + crop + resize trên isolate riêng (tránh block UI thread).
      final processedBytes = await compute(
        _processImage,
        _ProcessParams(
          bytes: bytes,
          cropWidthRatio: cropWidthRatio,
          cropHeightRatio: cropHeightRatio,
          maxLongSide: AppConstants.maxImageLongSide,
          jpegQuality: AppConstants.jpegQuality,
        ),
      );

      if (processedBytes == null) return null;

      // Lưu file vào thư mục app documents.
      final outputPath = await _generateOutputPath();
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(processedBytes);

      return outputPath;
    } catch (e) {
      debugPrint('ImageProcessingService error: $e');
      return null;
    }
  }

  // Hàm xử lý ảnh chạy trên isolate riêng biệt (top-level / static).
  //
  // Nhận [_ProcessParams] chứa bytes ảnh gốc và các thông số crop/resize.
  // Trả về bytes JPEG đã xử lý, hoặc `null` nếu decode thất bại.
  static Uint8List? _processImage(_ProcessParams params) {
    // 1. Decode ảnh gốc.
    final original = img.decodeImage(params.bytes);
    if (original == null) return null;

    // 2. Crop theo vùng overlay (giữa ảnh).
    final cropped = _cropCenter(
      original,
      params.cropWidthRatio,
      params.cropHeightRatio,
    );

    // 3. Resize nếu cạnh dài vượt quá giới hạn.
    final resized = _resizeIfNeeded(cropped, params.maxLongSide);

    // 4. Encode JPEG với chất lượng 85%.
    return Uint8List.fromList(
      img.encodeJpg(resized, quality: params.jpegQuality),
    );
  }

  // Crop vùng trung tâm của ảnh theo tỷ lệ width/height.
  static img.Image _cropCenter(
    img.Image source,
    double widthRatio,
    double heightRatio,
  ) {
    final cropW = (source.width * widthRatio).round();
    final cropH = (source.height * heightRatio).round();
    final x = ((source.width - cropW) / 2).round();
    final y = ((source.height - cropH) / 2).round();

    final cropped = img.copyCrop(
      source,
      x: x,
      y: y,
      width: cropW,
      height: cropH,
    );

    // Tăng cường tương phản nhẹ để chữ nổi rõ hơn trên ảnh chụp thật
    return img.adjustColor(
      cropped,
      contrast: 1.15,
      brightness: 1.05,
    );
  }

  // Resize ảnh nếu cạnh dài nhất vượt [maxLongSide].
  //
  // Giữ nguyên tỷ lệ khung hình (aspect ratio). Nếu ảnh đã đủ nhỏ,
  // trả về nguyên bản không resize.
  static img.Image _resizeIfNeeded(img.Image source, int maxLongSide) {
    final longestSide =
        source.width > source.height ? source.width : source.height;

    if (longestSide <= maxLongSide) return source;

    if (source.width > source.height) {
      return img.copyResize(source, width: maxLongSide);
    } else {
      return img.copyResize(source, height: maxLongSide);
    }
  }

  // Tạo đường dẫn output duy nhất trong thư mục receipts.
  //
  // Format: `<app_documents>/receipts/receipt_<timestamp>.jpg`
  static Future<String> _generateOutputPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    final receiptDir = Directory(p.join(appDir.path, AppConstants.receiptImageDir));

    if (!await receiptDir.exists()) {
      await receiptDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return p.join(receiptDir.path, 'receipt_$timestamp.jpg');
  }
}

// Tham số truyền vào isolate cho hàm xử lý ảnh.
class _ProcessParams {
  final Uint8List bytes;
  final double cropWidthRatio;
  final double cropHeightRatio;
  final int maxLongSide;
  final int jpegQuality;

  const _ProcessParams({
    required this.bytes,
    required this.cropWidthRatio,
    required this.cropHeightRatio,
    required this.maxLongSide,
    required this.jpegQuality,
  });
}
