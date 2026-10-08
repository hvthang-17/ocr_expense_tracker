import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ocr_expense_tracker/features/dashboard/models/chart_data.dart';
import 'package:ocr_expense_tracker/features/dashboard/services/chart_data_service.dart';
import 'package:ocr_expense_tracker/features/transaction/providers/expense_providers.dart';

// Provider tính toán toàn bộ số liệu thống kê Dashboard dựa trên danh sách giao dịch hiện có.
final dashboardSummaryProvider = Provider<AsyncValue<DashboardSummary>>((ref) {
  final asyncExpenses = ref.watch(expenseListProvider);

  return asyncExpenses.whenData((expenses) {
    return ChartDataService.getDashboardSummary(expenses);
  });
});
