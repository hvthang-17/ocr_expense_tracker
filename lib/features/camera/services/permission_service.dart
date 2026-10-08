import 'package:permission_handler/permission_handler.dart';

// Trạng thái quyền camera sau khi kiểm tra / yêu cầu.
enum CameraPermissionStatus {
  // Quyền đã được cấp — có thể mở camera.
  granted,

  // Người dùng từ chối — hiển thị thông báo + nút thử lại.
  denied,

  // Người dùng từ chối vĩnh viễn — cần mở Settings thủ công.
  permanentlyDenied,
}

// Dịch vụ xử lý quyền camera sử dụng permission_handler.
//
// Cung cấp hai hành động chính:
// - [checkAndRequest]: Kiểm tra trạng thái hiện tại, nếu chưa cấp thì yêu cầu.
// - [openSettings]: Mở trang cài đặt ứng dụng để người dùng cấp quyền thủ công.
class PermissionService {
  PermissionService._();

  // Kiểm tra quyền camera hiện tại; nếu chưa cấp, hiển thị dialog yêu cầu.
  //
  // Trả về [CameraPermissionStatus] phản ánh trạng thái cuối cùng.
  static Future<CameraPermissionStatus> checkAndRequest() async {
    var status = await Permission.camera.status;

    // Quyền đã được cấp hoặc bị giới hạn (iOS) — coi như granted.
    if (status.isGranted || status.isLimited) {
      return CameraPermissionStatus.granted;
    }

    // Người dùng đã từ chối vĩnh viễn — không thể hiện dialog, cần mở Settings.
    if (status.isPermanentlyDenied) {
      return CameraPermissionStatus.permanentlyDenied;
    }

    // Yêu cầu quyền lần đầu hoặc thử lại.
    status = await Permission.camera.request();

    if (status.isGranted || status.isLimited) {
      return CameraPermissionStatus.granted;
    }

    if (status.isPermanentlyDenied) {
      return CameraPermissionStatus.permanentlyDenied;
    }

    return CameraPermissionStatus.denied;
  }

  // Mở trang cài đặt quyền ứng dụng trên thiết bị.
  //
  // Trả về `true` nếu hệ điều hành mở Settings thành công.
  static Future<bool> openSettings() => openAppSettings();
}
