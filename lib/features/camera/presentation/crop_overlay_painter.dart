import 'package:flutter/material.dart';

// CustomPainter vẽ lớp phủ crop trên camera preview.
//
// Hiển thị:
// - Nền mờ (scrim) bán trong suốt bao phủ toàn bộ preview.
// - Khung chữ nhật bo góc ở giữa — "cửa sổ" trong suốt để đặt biên lai.
// - Viền trắng bo góc xung quanh khung.
class CropOverlayPainter extends CustomPainter {
  // Tỷ lệ chiều rộng của khung crop so với chiều rộng canvas (0.0–1.0).
  final double widthRatio;

  // Tỷ lệ chiều cao của khung crop so với chiều cao canvas (0.0–1.0).
  final double heightRatio;

  // Bán kính bo góc của khung crop (pixel).
  final double borderRadius;

  // Màu nền mờ xung quanh khung crop.
  final Color scrimColor;

  const CropOverlayPainter({
    this.widthRatio = 0.88,
    this.heightRatio = 0.55,
    this.borderRadius = 16.0,
    this.scrimColor = const Color(0x99000000),
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Tính kích thước và vị trí khung crop ở giữa canvas.
    final cropWidth = size.width * widthRatio;
    final cropHeight = size.height * heightRatio;
    final cropRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cropWidth,
      height: cropHeight,
    );
    final cropRRect = RRect.fromRectAndRadius(
      cropRect,
      Radius.circular(borderRadius),
    );

    // 2. Vẽ nền mờ bao phủ toàn canvas, trừ khung crop (dùng Path.combine).
    final scrimPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()..addRRect(cropRRect),
    );
    canvas.drawPath(
      scrimPath,
      Paint()..color = scrimColor,
    );

    // 3. Vẽ viền trắng xung quanh khung crop.
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(cropRRect, borderPaint);

    // 4. Vẽ 4 góc nhấn mạnh (corner brackets) để hướng dẫn canh biên lai.
    _drawCornerBrackets(canvas, cropRect);
  }

  // Vẽ 4 góc vuông nhấn mạnh ở 4 góc khung crop.
  void _drawCornerBrackets(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const len = 24.0; // Chiều dài mỗi cạnh góc
    final r = borderRadius;

    // Góc trên-trái
    canvas.drawPath(
      Path()
        ..moveTo(rect.left + r, rect.top)
        ..lineTo(rect.left + len, rect.top)
        ..moveTo(rect.left, rect.top + r)
        ..lineTo(rect.left, rect.top + len),
      paint,
    );
    // Góc trên-phải
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - r, rect.top)
        ..lineTo(rect.right - len, rect.top)
        ..moveTo(rect.right, rect.top + r)
        ..lineTo(rect.right, rect.top + len),
      paint,
    );
    // Góc dưới-trái
    canvas.drawPath(
      Path()
        ..moveTo(rect.left + r, rect.bottom)
        ..lineTo(rect.left + len, rect.bottom)
        ..moveTo(rect.left, rect.bottom - r)
        ..lineTo(rect.left, rect.bottom - len),
      paint,
    );
    // Góc dưới-phải
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - r, rect.bottom)
        ..lineTo(rect.right - len, rect.bottom)
        ..moveTo(rect.right, rect.bottom - r)
        ..lineTo(rect.right, rect.bottom - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CropOverlayPainter oldDelegate) =>
      widthRatio != oldDelegate.widthRatio ||
      heightRatio != oldDelegate.heightRatio ||
      borderRadius != oldDelegate.borderRadius;

  // Tính Rect crop tuyệt đối (pixel) cho kích thước preview đã cho.
  //
  // Dùng bởi [ImageProcessingService] để biết vùng ảnh cần cắt.
  Rect getCropRect(Size previewSize) {
    final cropWidth = previewSize.width * widthRatio;
    final cropHeight = previewSize.height * heightRatio;
    return Rect.fromCenter(
      center: Offset(previewSize.width / 2, previewSize.height / 2),
      width: cropWidth,
      height: cropHeight,
    );
  }
}
