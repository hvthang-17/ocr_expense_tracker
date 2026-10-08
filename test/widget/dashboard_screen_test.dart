import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/features/dashboard/presentation/dashboard_screen.dart';
import 'package:ocr_expense_tracker/features/dashboard/presentation/widgets/dashboard_empty_state.dart';
import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';
import 'package:ocr_expense_tracker/features/transaction/providers/expense_providers.dart';

void main() {
  Widget buildTestableWidget({List<Expense> initialExpenses = const []}) {
    return ProviderScope(
      overrides: [
        expenseListProvider.overrideWith(
          (ref) => _FakeExpenseListNotifier(initialExpenses),
        ),
      ],
      child: const MaterialApp(
        home: DashboardScreen(),
      ),
    );
  }

  testWidgets('DashboardScreen displays empty state when there are no expenses',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget(initialExpenses: []));
    await tester.pump();

    expect(find.byType(DashboardEmptyState), findsOneWidget);
    expect(find.text('Chưa có dữ liệu thống kê'), findsOneWidget);
    expect(find.text('Quét biên lai ngay'), findsOneWidget);
  });

  testWidgets('DashboardScreen displays summary cards and chart titles when expenses exist',
      (WidgetTester tester) async {
    final nowIso = DateTime.now().toIso8601String().substring(0, 10);
    final sampleExpense = Expense(
      id: 1,
      merchant: 'Highlands Coffee',
      transactionDate: nowIso,
      totalAmount: 65000,
      category: ExpenseCategory.food,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    await tester.pumpWidget(buildTestableWidget(initialExpenses: [sampleExpense]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    // Kiểm tra các thẻ tổng quan.
    expect(find.text('Tổng chi tiêu'), findsOneWidget);
    expect(find.text('65.000 VND'), findsWidgets);

    // Kiểm tra tiêu đề biểu đồ donut và biểu đồ cột.
    expect(find.text('Cơ cấu chi tiêu theo danh mục'), findsOneWidget);
    expect(find.text('Xu hướng chi tiêu 4 tuần gần đây'), findsOneWidget);

    // Kiểm tra chú thích của danh mục Ăn uống trên biểu đồ donut.
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('100.0%'), findsOneWidget);
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
