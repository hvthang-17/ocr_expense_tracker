import 'package:flutter/material.dart';
import 'package:ocr_expense_tracker/core/widgets/category_chip.dart';
import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';

// Widget chọn danh mục chi tiêu 5 nhóm bằng FilterChip với nhãn và icon.
class CategorySelector extends StatelessWidget {
  final ExpenseCategory? selectedCategory;
  final ValueChanged<ExpenseCategory> onCategorySelected;
  final String? errorText;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Danh mục chi tiêu',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasError ? Colors.red : Colors.transparent,
              width: 1,
            ),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ExpenseCategory.values.map((category) {
              final isSelected = selectedCategory == category;
              return CategoryChip(
                category: category,
                isSelected: isSelected,
                onSelected: (cat) => onCategorySelected(cat),
              );
            }).toList(),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
            ),
          ),
      ],
    );
  }
}
