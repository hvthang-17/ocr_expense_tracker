import 'package:ocr_expense_tracker/core/utils/date_formatter.dart';
import 'package:ocr_expense_tracker/features/dashboard/models/chart_data.dart';
import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';

// Dịch vụ tính toán số liệu thống kê & dữ liệu biểu đồ cho Dashboard.
class ChartDataService {
  ChartDataService._();

  // Phân tích danh sách giao dịch thành cơ cấu chi tiêu theo danh mục.
  static List<CategoryBreakdown> getCategoryBreakdown(List<Expense> expenses) {
    if (expenses.isEmpty) return const [];

    final Map<ExpenseCategory, int> categoryTotals = {};
    int grandTotal = 0;

    for (final expense in expenses) {
      final current = categoryTotals[expense.category] ?? 0;
      categoryTotals[expense.category] = current + expense.totalAmount;
      grandTotal += expense.totalAmount;
    }

    if (grandTotal == 0) return const [];

    final List<CategoryBreakdown> result = [];
    for (final entry in categoryTotals.entries) {
      if (entry.value > 0) {
        final percentage = (entry.value / grandTotal) * 100.0;
        result.add(CategoryBreakdown(
          category: entry.key,
          totalAmount: entry.value,
          percentage: percentage,
        ));
      }
    }

    // Sắp xếp giảm dần theo tổng số tiền chi tiêu
    result.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return result;
  }

  // Tính toán tổng chi tiêu theo 4 tuần gần đây (mặc định lấy theo referenceDate).
  static List<WeeklyTotal> getWeeklyTotals(
    List<Expense> expenses, {
    int numWeeks = 4,
    DateTime? referenceDate,
  }) {
    final ref = referenceDate ?? DateTime.now();

    final List<WeeklyTotal> weeklyTotals = [];

    // Tạo các khoảng tuần từ cũ nhất (T1) đến mới nhất (T4)
    for (int i = numWeeks - 1; i >= 0; i--) {
      final start = DateTime(
        ref.year,
        ref.month,
        ref.day,
      ).subtract(Duration(days: (i * 7) + 6));

      final end = DateTime(
        ref.year,
        ref.month,
        ref.day,
        23,
        59,
        59,
      ).subtract(Duration(days: i * 7));

      final weekIndex = numWeeks - i;
      final label = 'T$weekIndex';

      int sum = 0;
      for (final expense in expenses) {
        final date = DateFormatter.fromIso(expense.transactionDate);
        if (date != null && !date.isBefore(start) && !date.isAfter(end)) {
          sum += expense.totalAmount;
        }
      }

      weeklyTotals.add(WeeklyTotal(
        weekLabel: label,
        startDate: start,
        endDate: end,
        totalAmount: sum,
      ));
    }

    return weeklyTotals;
  }

  // Tổng hợp toàn bộ số liệu thống kê cho Dashboard.
  static DashboardSummary getDashboardSummary(
    List<Expense> expenses, {
    DateTime? referenceDate,
  }) {
    if (expenses.isEmpty) {
      return DashboardSummary(
        totalSpending: 0,
        monthlySpending: 0,
        averageTransaction: 0,
        totalCount: 0,
        categoryBreakdown: const [],
        weeklyTotals: getWeeklyTotals([], referenceDate: referenceDate),
      );
    }

    final ref = referenceDate ?? DateTime.now();
    int grandTotal = 0;
    int monthlyTotal = 0;

    for (final expense in expenses) {
      grandTotal += expense.totalAmount;

      final date = DateFormatter.fromIso(expense.transactionDate);
      if (date != null && date.year == ref.year && date.month == ref.month) {
        monthlyTotal += expense.totalAmount;
      }
    }

    final avg = grandTotal ~/ expenses.length;
    final breakdown = getCategoryBreakdown(expenses);
    final weekly = getWeeklyTotals(expenses, referenceDate: referenceDate);

    return DashboardSummary(
      totalSpending: grandTotal,
      monthlySpending: monthlyTotal,
      averageTransaction: avg,
      totalCount: expenses.length,
      categoryBreakdown: breakdown,
      weeklyTotals: weekly,
    );
  }
}
