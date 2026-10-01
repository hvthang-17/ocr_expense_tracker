import 'package:flutter/material.dart';
import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';

// Widget chip hiển thị và chọn danh mục chi tiêu.
class CategoryChip extends StatelessWidget {
  final ExpenseCategory category;
  final bool isSelected;
  final ValueChanged<ExpenseCategory>? onSelected;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(category.label),
      avatar: Icon(
        category.icon,
        size: 18,
        color: isSelected ? Colors.white : category.color,
      ),
      selected: isSelected,
      onSelected: onSelected != null ? (_) => onSelected!(category) : null,
      selectedColor: category.color,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
      ),
    );
  }
}
