import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ocr_expense_tracker/core/routes/app_routes.dart';
import 'package:ocr_expense_tracker/features/dashboard/providers/dashboard_provider.dart';
import 'package:ocr_expense_tracker/features/dashboard/presentation/widgets/bar_chart_card.dart';
import 'package:ocr_expense_tracker/features/dashboard/presentation/widgets/dashboard_empty_state.dart';
import 'package:ocr_expense_tracker/features/dashboard/presentation/widgets/donut_chart_card.dart';
import 'package:ocr_expense_tracker/features/dashboard/presentation/widgets/summary_cards.dart';
import 'package:ocr_expense_tracker/features/ocr/models/parsed_receipt.dart';
import 'package:ocr_expense_tracker/features/transaction/providers/expense_providers.dart';

// Màn hình Dashboard hiển thị tổng quan chỉ số chi tiêu & 2 biểu đồ custom bằng CustomPainter.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _chartAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    final result = await Navigator.of(context).pushNamed<ParsedReceipt>(
      AppRoutes.camera,
    );

    if (result != null && mounted) {
      Navigator.of(context).pushNamed(
        AppRoutes.review,
        arguments: result,
      );
    }
  }

  Future<void> _handleRefresh() async {
    ref.invalidate(expenseListProvider);
    _animController.reset();
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final asyncSummary = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
      ),
      body: asyncSummary.when(
        data: (summary) {
          if (summary.isEmpty) {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 150,
                  child: DashboardEmptyState(
                    onScanPressed: _openCamera,
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thẻ tổng quan các số liệu chính
                      SummaryCards(summary: summary),
                      const SizedBox(height: 16),

                      // Biểu đồ Donut cơ cấu theo danh mục
                      DonutChartCard(
                        items: summary.categoryBreakdown,
                        totalAmount: summary.totalSpending,
                        animationProgress: _chartAnimation.value,
                      ),
                      const SizedBox(height: 16),

                      // Biểu đồ Cột chi tiêu theo tuần
                      BarChartCard(
                        weeklyTotals: summary.weeklyTotals,
                        animationProgress: _chartAnimation.value,
                      ),
                      const SizedBox(height: 80), // Khoảng trống cho FAB
                    ],
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: SelectableText('Đã xảy ra lỗi khi tải dữ liệu: $err'),
        ),
      ),
    );
  }
}


