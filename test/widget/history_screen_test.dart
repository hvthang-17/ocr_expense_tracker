import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/core/routes/app_routes.dart';
import 'package:ocr_expense_tracker/features/history/presentation/history_screen.dart';
import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';
import 'package:ocr_expense_tracker/features/transaction/providers/expense_providers.dart';

void main() {
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
  ];

  Widget createWidgetUnderTest({List<Expense> expenses = const []}) {
    return ProviderScope(
      overrides: [
        expenseListProvider.overrideWith(
          (ref) => _FakeExpenseListNotifier(expenses),
        ),
      ],
      child: const MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: HistoryScreen(),
      ),
    );
  }

  testWidgets('displays empty state when there are no transactions',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(expenses: []));
    await tester.pumpAndSettle();

    expect(find.text('Chưa có giao dịch nào'), findsOneWidget);
    expect(find.text('Hãy quét biên lai hoặc thêm giao dịch mới'), findsOneWidget);
  });

  testWidgets('displays expense items when data exists',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(expenses: sampleExpenses));
    await tester.pumpAndSettle();

    expect(find.text('Phúc Long Coffee'), findsOneWidget);
    expect(find.text('85.000 VND'), findsOneWidget);
    expect(find.text('Nhà sách Fahasa'), findsOneWidget);
    expect(find.text('120.000 VND'), findsOneWidget);
  });

  testWidgets('search text field filters list by merchant',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(expenses: sampleExpenses));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Fahasa');
    await tester.pumpAndSettle();

    expect(find.text('Nhà sách Fahasa'), findsOneWidget);
    expect(find.text('Phúc Long Coffee'), findsNothing);
  });

  testWidgets('tapping Category chip filters list by category',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(expenses: sampleExpenses));
    await tester.pumpAndSettle();

    // Chạm vào chip "Học tập".
    await tester.tap(find.widgetWithText(ChoiceChip, 'Study'));
    await tester.pumpAndSettle();

    expect(find.text('Nhà sách Fahasa'), findsOneWidget);
    expect(find.text('Phúc Long Coffee'), findsNothing);
  });

  testWidgets('shows no results matching filter empty state with clear button',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(expenses: sampleExpenses));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'NonExistentStore');
    await tester.pumpAndSettle();

    expect(find.text('Không tìm thấy giao dịch phù hợp'), findsOneWidget);
    expect(find.text('Xóa bộ lọc'), findsOneWidget);

    // Chạm để xóa bộ lọc.
    await tester.tap(find.text('Xóa bộ lọc'));
    await tester.pumpAndSettle();

    expect(find.text('Phúc Long Coffee'), findsOneWidget);
    expect(find.text('Nhà sách Fahasa'), findsOneWidget);
  });

  testWidgets('tapping expense item navigates to detail screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(expenses: sampleExpenses));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Phúc Long Coffee'));
    await tester.pumpAndSettle();

    expect(find.text('Chi tiết giao dịch'), findsOneWidget);
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

