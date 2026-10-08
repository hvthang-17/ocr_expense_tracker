import 'package:flutter/material.dart';
import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';

// Dữ liệu tổng hợp theo danh mục dùng cho biểu đồ Donut và Legend.
class CategoryBreakdown {
  final ExpenseCategory category;
  final int totalAmount;
  final double percentage; // Tỷ lệ phần trăm từ 0.0 đến 100.0

  const CategoryBreakdown({
    required this.category,
    required this.totalAmount,
    required this.percentage,
  });

  Color get color => category.color;
  String get label => category.label;
}

// Dữ liệu tổng chi tiêu theo tuần dùng cho biểu đồ cột (Bar Chart).
class WeeklyTotal {
  final String weekLabel; // Ví dụ: "T1", "T2", "T3", "T4"
  final DateTime startDate;
  final DateTime endDate;
  final int totalAmount;

  const WeeklyTotal({
    required this.weekLabel,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
  });
}

// Tổng hợp toàn bộ số liệu thống kê cho Dashboard.
class DashboardSummary {
  final int totalSpending; // Tổng chi tiêu từ trước đến nay
  final int monthlySpending; // Chi tiêu trong tháng hiện tại
  final int averageTransaction; // Trung bình mỗi giao dịch
  final int totalCount; // Tổng số giao dịch
  final List<CategoryBreakdown> categoryBreakdown;
  final List<WeeklyTotal> weeklyTotals;

  const DashboardSummary({
    required this.totalSpending,
    required this.monthlySpending,
    required this.averageTransaction,
    required this.totalCount,
    required this.categoryBreakdown,
    required this.weeklyTotals,
  });

  bool get isEmpty => totalCount == 0 || totalSpending == 0;
}
