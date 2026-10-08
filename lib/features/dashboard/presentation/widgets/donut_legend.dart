import 'package:flutter/material.dart';
import 'package:ocr_expense_tracker/core/utils/currency_formatter.dart';
import 'package:ocr_expense_tracker/features/dashboard/models/chart_data.dart';

// Chú thích (Legend) hiển thị các danh mục chi tiêu kèm màu sắc, tổng tiền và phần trăm.
class DonutLegend extends StatelessWidget {
  final List<CategoryBreakdown> items;

  const DonutLegend({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              // Swatch màu & Icon danh mục
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: item.color.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.category.icon,
                  size: 16,
                  color: item.color,
                ),
              ),
              const SizedBox(width: 10),

              // Tên danh mục
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),

              // Tổng số tiền
              Text(
                CurrencyFormatter.format(item.totalAmount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),

              // Tỷ lệ phần trăm
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${item.percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
