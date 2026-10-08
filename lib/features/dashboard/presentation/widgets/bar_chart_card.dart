import 'package:flutter/material.dart';
import 'package:ocr_expense_tracker/features/dashboard/models/chart_data.dart';
import 'package:ocr_expense_tracker/features/dashboard/painters/bar_chart_painter.dart';

// Card chứa biểu đồ cột (Bar Chart) chi tiêu theo tuần.
class BarChartCard extends StatelessWidget {
  final List<WeeklyTotal> weeklyTotals;
  final double animationProgress;

  const BarChartCard({
    super.key,
    required this.weeklyTotals,
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
                  Icons.bar_chart,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Xu hướng chi tiêu 4 tuần gần đây',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Canvas biểu đồ cột
            SizedBox(
              height: 200,
              width: double.infinity,
              child: CustomPaint(
                painter: WeeklyBarChartPainter(
                  weeklyTotals: weeklyTotals,
                  animationProgress: animationProgress,
                  barColor: theme.colorScheme.primary,
                  gridColor: Colors.grey.shade300,
                  labelColor: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
