import 'package:flutter/material.dart';
import 'package:ocr_expense_tracker/core/utils/date_formatter.dart';
import 'package:ocr_expense_tracker/features/history/providers/history_filter_provider.dart';
import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';

// Row chứa các ChoiceChip lọc theo danh mục và ActionChip chọn khoảng ngày.
class HistoryFilterChips extends StatelessWidget {
  final HistoryFilterState filterState;
  final ValueChanged<ExpenseCategory?> onCategorySelected;
  final VoidCallback onPickDateRange;
  final VoidCallback onClearDateRange;

  const HistoryFilterChips({
    super.key,
    required this.filterState,
    required this.onCategorySelected,
    required this.onPickDateRange,
    required this.onClearDateRange,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Tất cả'),
            selected: filterState.selectedCategory == null,
            onSelected: (selected) {
              if (selected) onCategorySelected(null);
            },
          ),
          const SizedBox(width: 8),
          ...ExpenseCategory.values.map((category) {
            final isSelected = filterState.selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category.label),
                avatar: Icon(
                  category.icon,
                  size: 18,
                  color: isSelected ? Colors.white : category.color,
                ),
                selected: isSelected,
                selectedColor: category.color,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  onCategorySelected(selected ? category : null);
                },
              ),
            );
          }),
          ActionChip(
            avatar: Icon(
              Icons.date_range,
              size: 18,
              color: (filterState.startDate != null)
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            label: Text(
              (filterState.startDate != null && filterState.endDate != null)
                  ? '${DateFormatter.toDisplay(filterState.startDate!)} - ${DateFormatter.toDisplay(filterState.endDate!)}'
                  : 'Chọn ngày',
            ),
            onPressed: onPickDateRange,
          ),
          if (filterState.startDate != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              tooltip: 'Xóa lọc ngày',
              onPressed: onClearDateRange,
            ),
          ],
        ],
      ),
    );
  }
}
