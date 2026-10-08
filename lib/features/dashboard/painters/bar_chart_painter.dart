import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ocr_expense_tracker/core/utils/currency_formatter.dart';
import 'package:ocr_expense_tracker/features/dashboard/models/chart_data.dart';

// Painter tự vẽ biểu đồ cột (Bar Chart) chi tiêu theo tuần với hiệu ứng grow-up.
class WeeklyBarChartPainter extends CustomPainter {
  final List<WeeklyTotal> weeklyTotals;
  final double animationProgress;
  final Color barColor;
  final Color gridColor;
  final Color labelColor;

  const WeeklyBarChartPainter({
    required this.weeklyTotals,
    required this.animationProgress,
    this.barColor = const Color(0xFF0F5257),
    this.gridColor = const Color(0xFFE0E0E0),
    this.labelColor = const Color(0xFF757575),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (weeklyTotals.isEmpty) return;

    const double paddingLeft = 45.0; // Khoảng trống bên trái cho trục Y
    const double paddingBottom = 28.0; // Khoảng trống bên dưới cho trục X
    const double paddingTop = 24.0; // Khoảng trống phía trên cho nhãn số tiền

    final double chartWidth = size.width - paddingLeft - 16;
    final double chartHeight = size.height - paddingTop - paddingBottom;
    final double chartBottom = size.height - paddingBottom;

    // Tìm giá trị lớn nhất để làm quy chuẩn cho trục Y
    int maxAmount = 0;
    for (final item in weeklyTotals) {
      if (item.totalAmount > maxAmount) {
        maxAmount = item.totalAmount;
      }
    }
    // Nếu tất cả bằng 0, gán max mặc định 100k để vẽ trục
    final double maxY = maxAmount > 0 ? maxAmount.toDouble() : 100000.0;

    // 1. Vẽ các đường lưới ngang (Grid Lines) & Nhãn Trục Y (0, 50%, 100%)
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const int gridLevels = 2; // Bottom (0), Middle (50%), Top (100%)
    for (int i = 0; i <= gridLevels; i++) {
      final double y = chartBottom - (chartHeight * (i / gridLevels));

      // Vẽ đường kẻ ngang
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(size.width - 16, y),
        gridPaint,
      );

      // Nhãn trục Y
      final double val = (maxY * (i / gridLevels));
      final String label = CurrencyFormatter.formatCompact(val.toInt());

      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(fontSize: 10, color: labelColor),
        ),
        textAlign: TextAlign.right,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: paddingLeft - 6);
      textPainter.paint(
        canvas,
        Offset(paddingLeft - textPainter.width - 6, y - (textPainter.height / 2)),
      );
    }

    // 2. Vẽ các Cột (Bars) & Nhãn Trục X + Giá trị trên đỉnh cột
    final int count = weeklyTotals.length;
    final double itemWidth = chartWidth / count;
    final double barWidth = min(itemWidth * 0.45, 28.0);

    final barPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    final trackPaint = Paint()
      ..color = gridColor.withAlpha(50)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final item = weeklyTotals[i];
      final double centerX = paddingLeft + (i + 0.5) * itemWidth;
      final double barLeft = centerX - (barWidth / 2);

      // Vẽ cột xám mờ làm background track
      final trackRRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(barLeft, paddingTop, barWidth, chartHeight),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );
      canvas.drawRRect(trackRRect, trackPaint);

      // Tính chiều cao cột theo tỉ lệ & animation grow-up
      final double targetHeight = (item.totalAmount / maxY) * chartHeight;
      final double currentHeight = targetHeight * animationProgress.clamp(0.0, 1.0);

      if (currentHeight > 0) {
        final barRect = RRect.fromRectAndCorners(
          Rect.fromLTWH(
            barLeft,
            chartBottom - currentHeight,
            barWidth,
            currentHeight,
          ),
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
        );
        canvas.drawRRect(barRect, barPaint);
      }

      // Vẽ giá trị phía trên đỉnh cột (nếu > 0)
      if (item.totalAmount > 0 && animationProgress > 0.3) {
        final valText = CurrencyFormatter.formatCompact(item.totalAmount);
        final valPainter = TextPainter(
          text: TextSpan(
            text: valText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: barColor,
            ),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        valPainter.layout();
        final valY = chartBottom - currentHeight - valPainter.height - 4;
        valPainter.paint(
          canvas,
          Offset(centerX - (valPainter.width / 2), valY),
        );
      }

      // Vẽ nhãn trục X ("T1", "T2", ...) phía dưới cột
      final xPainter = TextPainter(
        text: TextSpan(
          text: item.weekLabel,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      xPainter.layout();
      xPainter.paint(
        canvas,
        Offset(centerX - (xPainter.width / 2), chartBottom + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant WeeklyBarChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.weeklyTotals != weeklyTotals ||
        oldDelegate.barColor != barColor ||
        oldDelegate.gridColor != gridColor;
  }
}
