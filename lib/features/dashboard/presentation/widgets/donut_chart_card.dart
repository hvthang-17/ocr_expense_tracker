import 'package:flutter/material.dart';
import 'package:ocr_expense_tracker/features/dashboard/models/chart_data.dart';
import 'package:ocr_expense_tracker/features/dashboard/painters/donut_chart_painter.dart';
import 'package:ocr_expense_tracker/features/dashboard/presentation/widgets/donut_legend.dart';

// Card chứa biểu đồ Donut và phần Chú thích (Legend) cơ cấu chi tiêu.
class DonutChartCard extends StatelessWidget {
  final List<CategoryBreakdown> items;
  final int totalAmount;
  final double animationProgress;

  const DonutChartCard({
    super.key,
    required this.items,
    required this.totalAmount,
    required this.animationProgress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pie_chart,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cơ cấu chi tiêu theo danh mục',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Biểu đồ Donut Canvas
            Center(
              child: SizedBox(
                width: 180,
                height: 180,
                child: CustomPaint(
                  painter: DonutChartPainter(
                    items: items,
                    animationProgress: animationProgress,
                    totalAmount: totalAmount,
                    emptyColor: Colors.grey.shade300,
                    centerTextColor: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Chú thích danh mục (Legend)
            DonutLegend(items: items),
          ],
        ),
      ),
    );
  }
}
