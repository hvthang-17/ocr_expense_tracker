import 'package:flutter/material.dart';
import 'package:ocr_expense_tracker/core/utils/currency_formatter.dart';
import 'package:ocr_expense_tracker/features/dashboard/models/chart_data.dart';

// Thẻ tổng quan các chỉ số chi tiêu chính trên Dashboard.
class SummaryCards extends StatelessWidget {
  final DashboardSummary summary;

  const SummaryCards({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Thẻ Tổng Chi Tiêu Chính
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng chi tiêu',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer
                              .withAlpha(200),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(summary.totalSpending),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 2 Thẻ Phụ: Chi tiêu tháng này & Trung bình giao dịch
        Row(
          children: [
            Expanded(
              child: _MetricSubCard(
                title: 'Chi tháng này',
                value: CurrencyFormatter.format(summary.monthlySpending),
                icon: Icons.calendar_month,
                color: Colors.teal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricSubCard(
                title: 'Trung bình/GD',
                value: CurrencyFormatter.format(summary.averageTransaction),
                icon: Icons.analytics,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricSubCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricSubCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
