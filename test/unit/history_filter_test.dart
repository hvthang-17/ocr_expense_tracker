import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/features/history/providers/history_filter_provider.dart';
import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';
import 'package:ocr_expense_tracker/features/transaction/providers/expense_providers.dart';

void main() {
  late ProviderContainer container;

  final sampleExpenses = [
    const Expense(
      id: 1,
      merchant: 'Phúc Long Coffee',
      transactionDate: '2026-09-15',
      totalAmount: 85000,
      category: ExpenseCategory.food,
      createdAt: '2026-09-15T10:00:00Z',
      updatedAt: '2026-09-15T10:00:00Z',
    ),
    const Expense(
      id: 2,
      merchant: 'Nhà sách Fahasa',
      transactionDate: '2026-09-14',
      totalAmount: 120000,
      category: ExpenseCategory.study,
      createdAt: '2026-09-14T10:00:00Z',
      updatedAt: '2026-09-14T10:00:00Z',
    ),
    const Expense(
      id: 3,
      merchant: 'Grab Bike',
      transactionDate: '2026-09-10',
      totalAmount: 35000,
      category: ExpenseCategory.travel,
      createdAt: '2026-09-10T10:00:00Z',
      updatedAt: '2026-09-10T10:00:00Z',
    ),
  ];

  setUp(() {
    container = ProviderContainer(
      overrides: [
        expenseListProvider.overrideWith(
          (ref) => _FakeExpenseListNotifier(sampleExpenses),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('filteredExpensesProvider & HistoryFilterNotifier', () {
    test('returns all expenses when no filter is applied', () {
      final filtered = container.read(filteredExpensesProvider).value;
      expect(filtered?.length, 3);
    });

    test('filters merchant case-insensitively', () {
      container
          .read(historyFilterProvider.notifier)
          .setSearchQuery('phúc long');

      final filtered = container.read(filteredExpensesProvider).value;
      expect(filtered?.length, 1);
      expect(filtered?.first.merchant, 'Phúc Long Coffee');
    });

    test('filters by expense category', () {
      container
          .read(historyFilterProvider.notifier)
          .setCategory(ExpenseCategory.study);

      final filtered = container.read(filteredExpensesProvider).value;
      expect(filtered?.length, 1);
      expect(filtered?.first.category, ExpenseCategory.study);
    });

    test('filters by date range inclusive', () {
      container.read(historyFilterProvider.notifier).setDateRange(
            DateTime(2026, 9, 11),
            DateTime(2026, 9, 15),
          );

      final filtered = container.read(filteredExpensesProvider).value;
      expect(filtered?.length, 2);
      expect(filtered?.map((e) => e.id), containsAll([1, 2]));
    });

    test('clears all filters correctly', () {
      container.read(historyFilterProvider.notifier).setSearchQuery('Grab');
      container
          .read(historyFilterProvider.notifier)
          .setCategory(ExpenseCategory.travel);
      expect(container.read(filteredExpensesProvider).value?.length, 1);

      container.read(historyFilterProvider.notifier).clearAllFilters();
      expect(container.read(filteredExpensesProvider).value?.length, 3);
    });
  });
}

class _FakeExpenseListNotifier extends StateNotifier<AsyncValue<List<Expense>>>
    implements ExpenseListNotifier {
  _FakeExpenseListNotifier(List<Expense> initialData)
      : super(AsyncValue.data(initialData));

  @override
  Future<int> addExpense(Expense expense) async => 1;

  @override
  Future<void> deleteExpense(int id) async {}

  @override
  Future<void> loadExpenses() async {}

  @override
  Future<void> updateExpense(Expense expense) async {}
}

