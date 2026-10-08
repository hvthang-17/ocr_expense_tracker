import 'package:flutter/material.dart';

// Trang hiển thị trạng thái trống trên Dashboard khi chưa có giao dịch nào.
class DashboardEmptyState extends StatelessWidget {
  final VoidCallback? onScanPressed;

  const DashboardEmptyState({
    super.key,
    this.onScanPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.insights,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Chưa có dữ liệu thống kê',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy quét hoặc thêm hóa đơn đầu tiên để xem phân tích cơ cấu chi tiêu và xu hướng hàng tuần.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onScanPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onScanPressed,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Quét biên lai ngay'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
