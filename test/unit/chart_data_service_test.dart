import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/features/dashboard/services/chart_data_service.dart';
import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';

void main() {
  group('ChartDataService Unit Tests', () {
    final refDate = DateTime(2026, 10, 8); // Thứ 5, 08/10/2026

    const sampleExpenses = [
      Expense(
        id: 1,
        merchant: 'Highlands Coffee',
        transactionDate: '2026-10-08', // Trong T4 (02/10 - 08/10)
        totalAmount: 50000,
        category: ExpenseCategory.food,
        createdAt: '2026-10-08T10:00:00Z',
        updatedAt: '2026-10-08T10:00:00Z',
      ),
      Expense(
        id: 2,
        merchant: 'Nhà sách Fahasa',
        transactionDate: '2026-10-07', // Trong T4
        totalAmount: 150000,
        category: ExpenseCategory.study,
        createdAt: '2026-10-07T10:00:00Z',
        updatedAt: '2026-10-07T10:00:00Z',
      ),
      Expense(
        id: 3,
        merchant: 'Grab Bike',
        transactionDate: '2026-10-01', // Trong T3 (25/09 - 01/10)
        totalAmount: 100000,
        category: ExpenseCategory.travel,
        createdAt: '2026-10-01T10:00:00Z',
        updatedAt: '2026-10-01T10:00:00Z',
      ),
      Expense(
        id: 4,
        merchant: 'Phúc Long',
        transactionDate: '2026-10-08', // Trong T4
        totalAmount: 100000,
        category: ExpenseCategory.food,
        createdAt: '2026-10-08T11:00:00Z',
        updatedAt: '2026-10-08T11:00:00Z',
      ),
      Expense(
        id: 5,
        merchant: 'CGV Cinema',
        transactionDate: '2026-09-15', // Trong T1 (11/09 - 17/09)
        totalAmount: 200000,
        category: ExpenseCategory.entertainment,
        createdAt: '2026-09-15T10:00:00Z',
        updatedAt: '2026-09-15T10:00:00Z',
      ),
    ];

    test('getCategoryBreakdown returns empty list when expenses is empty', () {
      final breakdown = ChartDataService.getCategoryBreakdown([]);
      expect(breakdown, isEmpty);
    });

    test('getCategoryBreakdown aggregates totals and calculates percentages correctly', () {
      final breakdown = ChartDataService.getCategoryBreakdown(sampleExpenses);

      expect(breakdown.length, 4);

      // Food total: 50,000 + 100,000 = 150,000
      // Study total: 150,000
      // Entertainment total: 200,000
      // Travel total: 100,000
      // Grand total = 600,000

      // Món nhiều tiền nhất đứng đầu (Entertainment: 200,000)
      expect(breakdown.first.category, ExpenseCategory.entertainment);
      expect(breakdown.first.totalAmount, 200000);
      expect(breakdown.first.percentage, closeTo(33.33, 0.1));

      // Kiểm tra tổng percentage gần bằng 100%
      final totalPercent = breakdown.fold<double>(0.0, (sum, e) => sum + e.percentage);
      expect(totalPercent, closeTo(100.0, 0.01));
    });

    test('getWeeklyTotals returns 4 week buckets with correct totals', () {
      final weekly = ChartDataService.getWeeklyTotals(
        sampleExpenses,
        referenceDate: refDate,
      );

      expect(weekly.length, 4);
      expect(weekly[0].weekLabel, 'T1');
      expect(weekly[1].weekLabel, 'T2');
      expect(weekly[2].weekLabel, 'T3');
      expect(weekly[3].weekLabel, 'T4');

      // T4 (02/10 - 08/10): Highlands (50k) + Fahasa (150k) + Phúc Long (100k) = 300,000
      expect(weekly[3].totalAmount, 300000);

      // T3 (25/09 - 01/10): Grab Bike (100k) = 100,000
      expect(weekly[2].totalAmount, 100000);

      // T2 (18/09 - 24/09): 0
      expect(weekly[1].totalAmount, 0);

      // T1 (11/09 - 17/09): CGV Cinema (200k) = 200,000
      expect(weekly[0].totalAmount, 200000);
    });

    test('getDashboardSummary calculates overall metrics correctly', () {
      final summary = ChartDataService.getDashboardSummary(
        sampleExpenses,
        referenceDate: refDate,
      );

      expect(summary.isEmpty, false);
      expect(summary.totalCount, 5);
      expect(summary.totalSpending, 600000);
      expect(summary.averageTransaction, 120000);

      // Giao dịch tháng 10/2026: 50k + 150k + 100k + 100k = 400,000
      expect(summary.monthlySpending, 400000);
    });

    test('getDashboardSummary handles zero expenses without crash or divide-by-zero', () {
      final summary = ChartDataService.getDashboardSummary(
        [],
        referenceDate: refDate,
      );

      expect(summary.isEmpty, true);
      expect(summary.totalCount, 0);
      expect(summary.totalSpending, 0);
      expect(summary.monthlySpending, 0);
      expect(summary.averageTransaction, 0);
      expect(summary.categoryBreakdown, isEmpty);
      expect(summary.weeklyTotals.length, 4);
      expect(summary.weeklyTotals.every((w) => w.totalAmount == 0), true);
    });
  });
}
