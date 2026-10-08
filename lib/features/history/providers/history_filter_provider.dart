import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';
import 'package:ocr_expense_tracker/features/transaction/providers/expense_providers.dart';

// State chứa các tiêu chí lọc cho danh sách lịch sử giao dịch.
class HistoryFilterState {
  final String searchQuery;
  final ExpenseCategory? selectedCategory;
  final DateTime? startDate;
  final DateTime? endDate;

  const HistoryFilterState({
    this.searchQuery = '',
    this.selectedCategory,
    this.startDate,
    this.endDate,
  });

  // Kiểm tra xem có bất kỳ bộ lọc nào đang được kích hoạt hay không.
  bool get hasActiveFilters =>
      searchQuery.trim().isNotEmpty ||
      selectedCategory != null ||
      startDate != null ||
      endDate != null;

  HistoryFilterState copyWith({
    String? searchQuery,
    ExpenseCategory? selectedCategory,
    bool clearCategory = false,
    DateTime? startDate,
    DateTime? endDate,
    bool clearDateRange = false,
  }) {
    return HistoryFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      startDate: clearDateRange ? null : (startDate ?? this.startDate),
      endDate: clearDateRange ? null : (endDate ?? this.endDate),
    );
  }
}

// StateNotifier quản lý trạng thái bộ lọc lịch sử.
class HistoryFilterNotifier extends StateNotifier<HistoryFilterState> {
  HistoryFilterNotifier() : super(const HistoryFilterState());

  // Cập nhật từ khóa tìm kiếm theo tên cửa hàng.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  // Cập nhật danh mục chi tiêu được chọn (hoặc null để chọn tất cả).
  void setCategory(ExpenseCategory? category) {
    if (category == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  // Cập nhật khoảng thời gian lọc (start, end).
  void setDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      state = state.copyWith(clearDateRange: true);
    } else {
      state = state.copyWith(startDate: start, endDate: end);
    }
  }

  // Xóa toàn bộ bộ lọc về mặc định.
  void clearAllFilters() {
    state = const HistoryFilterState();
  }
}

// Provider quản lý trạng thái bộ lọc lịch sử giao dịch.
final historyFilterProvider =
    StateNotifierProvider<HistoryFilterNotifier, HistoryFilterState>((ref) {
  return HistoryFilterNotifier();
});

// Provider tính toán danh sách giao dịch đã được lọc dựa trên historyFilterProvider.
final filteredExpensesProvider = Provider<AsyncValue<List<Expense>>>((ref) {
  final asyncExpenses = ref.watch(expenseListProvider);
  final filter = ref.watch(historyFilterProvider);

  return asyncExpenses.whenData((expenses) {
    return expenses.where((expense) {
      // 1. Tìm kiếm theo tên cửa hàng (không phân biệt hoa/thường)
      if (filter.searchQuery.trim().isNotEmpty) {
        final query = filter.searchQuery.trim().toLowerCase();
        if (!expense.merchant.toLowerCase().contains(query)) {
          return false;
        }
      }

      // 2. Lọc theo danh mục chi tiêu
      if (filter.selectedCategory != null &&
          expense.category != filter.selectedCategory) {
        return false;
      }

      // 3. Lọc theo khoảng ngày (startDate <= transactionDate <= endDate)
      if (filter.startDate != null || filter.endDate != null) {
        final expenseDate = DateTime.tryParse(expense.transactionDate);
        if (expenseDate == null) return false;

        if (filter.startDate != null) {
          final start = DateTime(
            filter.startDate!.year,
            filter.startDate!.month,
            filter.startDate!.day,
          );
          if (expenseDate.isBefore(start)) {
            return false;
          }
        }

        if (filter.endDate != null) {
          final end = DateTime(
            filter.endDate!.year,
            filter.endDate!.month,
            filter.endDate!.day,
            23,
            59,
            59,
          );
          if (expenseDate.isAfter(end)) {
            return false;
          }
        }
      }

      return true;
    }).toList();
  });
});

