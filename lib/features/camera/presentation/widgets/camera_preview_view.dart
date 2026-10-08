import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:ocr_expense_tracker/features/camera/presentation/crop_overlay_painter.dart';

// Widget hiển thị xem trước camera, đèn flash, chạm lấy nét và nút chụp ảnh.
class CameraPreviewView extends StatelessWidget {
  final CameraController controller;
  final CropOverlayPainter cropOverlay;
  final IconData flashIcon;
  final bool isCapturing;
  final bool isProcessing;
  final String processingMessage;
  final VoidCallback onClose;
  final VoidCallback onToggleFlash;
  final Function(TapDownDetails, BoxConstraints) onTapToFocus;
  final VoidCallback onCapture;

  const CameraPreviewView({
    super.key,
    required this.controller,
    required this.cropOverlay,
    required this.flashIcon,
    required this.isCapturing,
    required this.isProcessing,
    this.processingMessage = 'Đang xử lý ảnh...',
    required this.onClose,
    required this.onToggleFlash,
    required this.onTapToFocus,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: 'Đóng',
              ),
              IconButton(
                onPressed: onToggleFlash,
                icon: Icon(flashIcon, color: Colors.white),
                tooltip: 'Flash',
              ),
            ],
          ),
        ),

        // Live preview + Overlay
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTapDown: (details) => onTapToFocus(details, constraints),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRect(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: controller.value.previewSize?.height ?? 1,
                          height: controller.value.previewSize?.width ?? 1,
                          child: CameraPreview(controller),
                        ),
                      ),
                    ),
                    CustomPaint(painter: cropOverlay, size: Size.infinite),
                  ],
                ),
              );
            },
          ),
        ),

        // Bottom bar
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Đặt biên lai trong khung',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              isProcessing
                  ? Column(
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 8),
                        Text(
                          processingMessage,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    )
                  : GestureDetector(
                      onTap: isCapturing ? null : onCapture,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCapturing ? Colors.grey : Colors.white,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
