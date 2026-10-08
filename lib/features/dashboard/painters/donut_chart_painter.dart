import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ocr_expense_tracker/core/utils/currency_formatter.dart';
import 'package:ocr_expense_tracker/features/dashboard/models/chart_data.dart';

// Painter tự vẽ biểu đồ Donut hiển thị cơ cấu chi tiêu theo danh mục.
class DonutChartPainter extends CustomPainter {
  final List<CategoryBreakdown> items;
  final double animationProgress;
  final int totalAmount;
  final Color emptyColor;
  final Color centerTextColor;

  const DonutChartPainter({
    required this.items,
    required this.animationProgress,
    required this.totalAmount,
    this.emptyColor = const Color(0xFFE0E0E0),
    this.centerTextColor = const Color(0xFF333333),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = min(size.width, size.height) * 0.16;
    final radius = (min(size.width, size.height) - strokeWidth) / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Nếu không có dữ liệu hoặc tổng tiền bằng 0, vẽ vòng tròn xám rỗng
    if (items.isEmpty || totalAmount <= 0) {
      final emptyPaint = Paint()
        ..color = emptyColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawArc(rect, 0, 2 * pi, false, emptyPaint);

      _drawCenterText(canvas, center, '0 VND');
      return;
    }

    // Lấy tổng số tiền để tính tỷ lệ sweep angle
    double startAngle = -pi / 2; // Khởi đầu từ đỉnh (12 giờ)

    for (final item in items) {
      final sweepAngle = (item.totalAmount / totalAmount) *
          2 *
          pi *
          animationProgress.clamp(0.0, 1.0);

      if (sweepAngle > 0) {
        final paint = Paint()
          ..color = item.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt;

        // Tránh khoảng trắng nếu chỉ có 1 phần duy nhất
        final gap = items.length > 1 ? 0.04 : 0.0;
        final drawSweep = max(0.0, sweepAngle - gap);

        canvas.drawArc(rect, startAngle + (gap / 2), drawSweep, false, paint);
        startAngle += sweepAngle;
      }
    }

    _drawCenterText(canvas, center, CurrencyFormatter.format(totalAmount));
  }

  // Vẽ văn bản hiển thị tổng số tiền ở trung tâm biểu đồ Donut.
  void _drawCenterText(Canvas canvas, Offset center, String text) {
    const titleSpan = TextSpan(
      text: 'Tổng số\n',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey,
        height: 1.2,
      ),
    );

    final valueSpan = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: centerTextColor,
      ),
    );

    final textPainter = TextPainter(
      text: TextSpan(children: [titleSpan, valueSpan]),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: 140);
    final textOffset = Offset(
      center.dx - (textPainter.width / 2),
      center.dy - (textPainter.height / 2),
    );
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.items != items ||
        oldDelegate.totalAmount != totalAmount ||
        oldDelegate.emptyColor != emptyColor;
  }
}
