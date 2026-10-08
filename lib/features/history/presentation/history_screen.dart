import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ocr_expense_tracker/features/history/presentation/widgets/expense_list_item.dart';
import 'package:ocr_expense_tracker/features/history/presentation/widgets/history_empty_state.dart';
import 'package:ocr_expense_tracker/features/history/presentation/widgets/history_filter_chips.dart';
import 'package:ocr_expense_tracker/features/history/presentation/widgets/history_search_bar.dart';
import 'package:ocr_expense_tracker/features/history/providers/history_filter_provider.dart';
import 'package:ocr_expense_tracker/features/transaction/providers/expense_providers.dart';

// Màn hình Lịch sử giao dịch hỗ trợ tìm kiếm, lọc theo danh mục và khoảng thời gian.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final currentSearch = ref.read(historyFilterProvider).searchQuery;
    _searchController = TextEditingController(text: currentSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final filter = ref.read(historyFilterProvider);
    final firstDate = DateTime(2020);
    final lastDate = DateTime(2035);

    final initialRange = (filter.startDate != null && filter.endDate != null)
        ? DateTimeRange(start: filter.startDate!, end: filter.endDate!)
        : null;

    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Chọn khoảng ngày giao dịch',
      cancelText: 'Hủy',
      confirmText: 'Áp dụng',
    );

    if (picked != null) {
      ref
          .read(historyFilterProvider.notifier)
          .setDateRange(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(historyFilterProvider);
    final asyncExpenses = ref.watch(filteredExpensesProvider);
    final totalExpensesCount =
        ref.watch(expenseListProvider).valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử giao dịch'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Search Bar
          HistorySearchBar(
            controller: _searchController,
            searchQuery: filterState.searchQuery,
            onChanged: (query) {
              ref.read(historyFilterProvider.notifier).setSearchQuery(query);
            },
            onClear: () {
              _searchController.clear();
              ref.read(historyFilterProvider.notifier).setSearchQuery('');
            },
          ),

          // 2. Filter Chips
          HistoryFilterChips(
            filterState: filterState,
            onCategorySelected: (category) {
              ref.read(historyFilterProvider.notifier).setCategory(category);
            },
            onPickDateRange: _pickDateRange,
            onClearDateRange: () {
              ref.read(historyFilterProvider.notifier).setDateRange(null, null);
            },
          ),

          const Divider(height: 16),

          // 3. ListView / Empty State
          Expanded(
            child: asyncExpenses.when(
              data: (expenses) {
                if (expenses.isEmpty) {
                  return HistoryEmptyState(
                    hasTotalExpenses: totalExpensesCount > 0,
                    hasFilters: filterState.hasActiveFilters,
                    onClearFilters: () {
                      _searchController.clear();
                      ref.read(historyFilterProvider.notifier).clearAllFilters();
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(expenseListProvider.notifier).loadExpenses();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      return ExpenseListItem(expense: expenses[index]);
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Text(
                  'Đã xảy ra lỗi: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

