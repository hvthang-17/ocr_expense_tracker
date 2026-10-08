import 'package:flutter/material.dart';

// Widget hiển thị trạng thái danh sách rỗng (chưa có giao dịch hoặc không tìm thấy kết quả).
class HistoryEmptyState extends StatelessWidget {
  final bool hasTotalExpenses;
  final bool hasFilters;
  final VoidCallback onClearFilters;

  const HistoryEmptyState({
    super.key,
    required this.hasTotalExpenses,
    required this.hasFilters,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!hasTotalExpenses) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có giao dịch nào',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy quét biên lai hoặc thêm giao dịch mới',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy giao dịch phù hợp',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử thay đổi từ khóa hoặc điều kiện lọc',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.filter_alt_off),
                label: const Text('Xóa bộ lọc'),
                onPressed: onClearFilters,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
