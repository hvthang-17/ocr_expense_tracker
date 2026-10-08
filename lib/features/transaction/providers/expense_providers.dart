import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ocr_expense_tracker/features/transaction/data/expense_repository.dart';
import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';

// Provider cung cấp instance duy nhất của ExpenseRepository.
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});

// StateNotifier quản lý danh sách chi tiêu và tự động cập nhật UI.
class ExpenseListNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  final ExpenseRepository _repository;

  ExpenseListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadExpenses();
  }

  // Tải lại toàn bộ danh sách chi tiêu từ cơ sở dữ liệu SQLite.
  Future<void> loadExpenses() async {
    try {
      final expenses = await _repository.getAllExpenses();
      if (!mounted) return;
      state = AsyncValue.data(expenses);
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
  }

  // Thêm một giao dịch chi tiêu mới và làm mới danh sách.
  Future<int> addExpense(Expense expense) async {
    final id = await _repository.insertExpense(expense);
    await loadExpenses();
    return id;
  }

  // Cập nhật thông tin giao dịch chi tiêu đã có.
  Future<void> updateExpense(Expense expense) async {
    await _repository.updateExpense(expense);
    await loadExpenses();
  }

  // Xóa giao dịch chi tiêu theo ID và làm mới danh sách.
  Future<void> deleteExpense(int id) async {
    await _repository.deleteExpense(id);
    await loadExpenses();
  }
}

// Provider cung cấp danh sách chi tiêu và cho phép thêm/sửa/xóa.
final expenseListProvider =
    StateNotifierProvider<ExpenseListNotifier, AsyncValue<List<Expense>>>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  return ExpenseListNotifier(repository);
});

// Provider family truy xuất giao dịch theo ID từ state hiện tại.
final expenseDetailProvider = Provider.family<Expense?, int>((ref, id) {
  final asyncExpenses = ref.watch(expenseListProvider);
  return asyncExpenses.when(
    data: (expenses) {
      try {
        return expenses.firstWhere((e) => e.id == id);
      } catch (_) {
        return null;
      }
    },
    loading: () => null,
    error: (error, stackTrace) => null,
  );
});
