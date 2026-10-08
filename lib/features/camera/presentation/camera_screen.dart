import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:ocr_expense_tracker/features/camera/presentation/capture_preview_screen.dart';
import 'package:ocr_expense_tracker/features/camera/presentation/crop_overlay_painter.dart';
import 'package:ocr_expense_tracker/features/camera/presentation/widgets/camera_permission_view.dart';
import 'package:ocr_expense_tracker/features/camera/presentation/widgets/camera_preview_view.dart';
import 'package:ocr_expense_tracker/features/camera/services/image_processing_service.dart';
import 'package:ocr_expense_tracker/features/camera/services/permission_service.dart';
import 'package:ocr_expense_tracker/features/ocr/services/ocr_service.dart';

// Màn hình camera chính điều phối khởi tạo, chụp ảnh, xử lý và xem trước.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  CameraPermissionStatus _permissionStatus = CameraPermissionStatus.denied;
  bool _isInitializing = true;
  bool _isCapturing = false;
  bool _isProcessing = false;
  String _processingMessage = 'Đang xử lý ảnh...';
  String? _errorMessage;

  FlashMode _flashMode = FlashMode.off;
  final _cropOverlay = const CropOverlayPainter();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    final status = await PermissionService.checkAndRequest();
    if (!mounted) return;
    setState(() => _permissionStatus = status);

    if (status != CameraPermissionStatus.granted) {
      setState(() => _isInitializing = false);
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Thiết bị không có camera.';
          _isInitializing = false;
        });
        return;
      }

      final rearCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        rearCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      await _controller!.setFlashMode(_flashMode);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Không thể khởi tạo camera: $e';
        _isInitializing = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() => _isInitializing = false);
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final nextMode = switch (_flashMode) {
      FlashMode.off => FlashMode.torch,
      FlashMode.torch => FlashMode.auto,
      FlashMode.auto => FlashMode.off,
      _ => FlashMode.off,
    };

    try {
      await controller.setFlashMode(nextMode);
      setState(() => _flashMode = nextMode);
    } catch (e) {
      debugPrint('Flash error: $e');
    }
  }

  IconData get _flashIcon => switch (_flashMode) {
        FlashMode.off => Icons.flash_off,
        FlashMode.torch => Icons.flash_on,
        FlashMode.auto => Icons.flash_auto,
        _ => Icons.flash_off,
      };

  Future<void> _onTapToFocus(TapDownDetails details, BoxConstraints constraints) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final x = (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
    final y = (details.localPosition.dy / constraints.maxHeight).clamp(0.0, 1.0);

    try {
      await controller.setFocusPoint(Offset(x, y));
      await controller.setExposurePoint(Offset(x, y));
    } catch (e) {
      debugPrint('Focus error: $e');
    }
  }

  Future<void> _captureAndProcess() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (_isCapturing || _isProcessing) return;

    setState(() => _isCapturing = true);

    try {
      final xFile = await controller.takePicture();
      if (!mounted) return;
      setState(() => _isCapturing = false);

      final confirmed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => CapturePreviewScreen(imagePath: xFile.path),
        ),
      );

      if (confirmed != true || !mounted) return;

      // Bước 1: Crop & nén ảnh.
      setState(() {
        _isProcessing = true;
        _processingMessage = 'Đang xử lý ảnh...';
      });

      final processedPath = await ImageProcessingService.processReceipt(
        imagePath: xFile.path,
        cropWidthRatio: _cropOverlay.widthRatio,
        cropHeightRatio: _cropOverlay.heightRatio,
      );

      try {
        await File(xFile.path).delete();
      } catch (_) {}

      if (processedPath == null || !mounted) {
        setState(() => _isProcessing = false);
        if (mounted) {
          _showSnackBarError('Không thể xử lý ảnh. Vui lòng thử lại.');
        }
        return;
      }

      // Bước 2: OCR nhận dạng văn bản + phân tích biên lai.
      setState(() => _processingMessage = 'Đang nhận dạng văn bản...');

      final parsedReceipt = await OcrService.recognizeAndParse(processedPath);

      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (parsedReceipt != null) {
        Navigator.of(context).pop(
          parsedReceipt.copyWith(imagePath: processedPath),
        );
      } else {
        _showSnackBarError('Không thể nhận dạng văn bản. Vui lòng thử lại.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCapturing = false;
        _isProcessing = false;
      });
      _showSnackBarError('Lỗi chụp ảnh: $e');
    }
  }

  void _showSnackBarError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isInitializing) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text('Đang khởi tạo camera...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    if (_permissionStatus != CameraPermissionStatus.granted) {
      return CameraPermissionView(
        status: _permissionStatus,
        onRetry: _initializeCamera,
        onBackPressed: () => Navigator.of(context).pop(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _initializeCamera,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final controller = _controller!;
    return CameraPreviewView(
      controller: controller,
      cropOverlay: _cropOverlay,
      flashIcon: _flashIcon,
      isCapturing: _isCapturing,
      isProcessing: _isProcessing,
      processingMessage: _processingMessage,
      onClose: () => Navigator.of(context).pop(),
      onToggleFlash: _toggleFlash,
      onTapToFocus: _onTapToFocus,
      onCapture: _captureAndProcess,
    );
  }
}
