import 'package:flutter/material.dart';
import 'package:ocr_expense_tracker/features/camera/services/permission_service.dart';

// Widget hiển thị thông báo và các nút hành động khi camera bị từ chối hoặc có lỗi.
class CameraPermissionView extends StatelessWidget {
  final CameraPermissionStatus status;
  final VoidCallback onRetry;
  final VoidCallback onBackPressed;

  const CameraPermissionView({
    super.key,
    required this.status,
    required this.onRetry,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isPermanent = status == CameraPermissionStatus.permanentlyDenied;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 72,
              color: Colors.white54,
            ),
            const SizedBox(height: 24),
            const Text(
              'Cần quyền truy cập Camera',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isPermanent
                  ? 'Bạn đã từ chối quyền camera vĩnh viễn.\nVui lòng mở Cài đặt để cấp quyền.'
                  : 'Ứng dụng cần quyền camera để chụp\nvà quét biên lai.',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (isPermanent)
              FilledButton.icon(
                onPressed: () => PermissionService.openSettings(),
                icon: const Icon(Icons.settings),
                label: const Text('Mở Cài đặt'),
              )
            else
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onBackPressed,
              child: const Text(
                'Quay lại',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
