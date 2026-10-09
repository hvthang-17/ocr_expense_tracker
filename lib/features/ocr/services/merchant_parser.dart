// Bộ phân tích tên cửa hàng / thương hiệu từ văn bản OCR của biên lai.
class MerchantParser {
  // Các từ khóa loại trừ cho dòng không phải là tên cửa hàng
  static final List<String> _excludeKeywords = [
    'hóa đơn',
    'hoá đơn',
    'biên lai',
    'phần mềm',
    'phieu thanh toan',
    'phiếu thanh toán',
    'phiếu xuất kho',
    'receipt',
    'invoice',
    'vat',
    'gtgt',
    'mã số thuế',
    'ma so thue',
    'mst',
    'địa chỉ',
    'dia chi',
    'đ/c',
    'd/c',
    'đc:',
    'dc:',
    'đc ',
    'dc ',
    'sđt',
    'sdt',
    'tel',
    'phone',
    'hotline',
    'ngày',
    'ngay',
    'date',
    'thời gian',
    'thoi gian',
    'khách hàng',
    'nhân viên',
    'thu ngân',
    'chào mừng',
    'xin cảm ơn',
    'thank you',
    'welcome',
    'www.',
    'http',
    'facebook',
    'fb.com',
    'instagram',
    'zalo',
    'wifi',
    'pass:',
    'mật khẩu',
  ];

  // Regex phát hiện chuỗi chỉ chứa ký tự đặc biệt hoặc số
  static final RegExp _noiseLineRegex = RegExp(r'^[\d\s\-_=.*+#@!$%^&*()]+$');

  // Regex phát hiện dòng bắt đầu bằng tiền tố địa chỉ hoặc số điện thoại
  static final RegExp _prefixAddressOrTelRegex = RegExp(
    r'^(đc|dc|đ/c|d/c|địa chỉ|sđt|sdt|tel|phone|hotline|mst)\b',
    caseSensitive: false,
  );

  // Phân tích văn bản OCR và trả về tên cửa hàng.
  static String? parse(String rawText) {
    if (rawText.trim().isEmpty) return null;

    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) return null;

    // Duyệt qua 5 dòng đầu tiên để tìm tên thương hiệu hợp lệ nhất
    final maxCheckLines = lines.length < 5 ? lines.length : 5;

    for (var i = 0; i < maxCheckLines; i++) {
      final line = lines[i];

      // Bỏ qua dòng rác, dòng chỉ gồm gạch ngang, ký tự đặc biệt hoặc toàn số
      if (_noiseLineRegex.hasMatch(line)) continue;

      // Bỏ qua dòng bắt đầu bằng địa chỉ, sđt, mst
      if (_prefixAddressOrTelRegex.hasMatch(line)) continue;

      final lineLower = line.toLowerCase();

      // Bỏ qua dòng chứa các từ khóa loại trừ (hóa đơn, mã số thuế, địa chỉ, sđt...)
      final containsExclude =
          _excludeKeywords.any((kw) => lineLower.contains(kw));
      if (containsExclude) continue;

      // Làm sạch tên cửa hàng
      final cleanedMerchant = _cleanMerchantName(line);
      if (cleanedMerchant.isNotEmpty && cleanedMerchant.length >= 2) {
        return cleanedMerchant;
      }
    }

    // Dự phòng: Lấy dòng đầu tiên không bị trống sau khi làm sạch nếu chưa tìm thấy
    for (final line in lines) {
      if (_noiseLineRegex.hasMatch(line)) continue;
      if (_prefixAddressOrTelRegex.hasMatch(line)) continue;

      final cleaned = _cleanMerchantName(line);
      if (cleaned.isNotEmpty && cleaned.length >= 2) {
        return cleaned;
      }
    }

    return null;
  }

  // Làm sạch tên cửa hàng (xóa ký tự rác ở hai đầu, chuẩn hóa khoảng trắng).
  static String _cleanMerchantName(String rawName) {
    var cleaned = rawName
        .replaceAll(RegExp(r'^[^\w\s\p{L}+]+|[^\w\s\p{L}+]+$', unicode: true), '')
        .trim();

    // Giới hạn độ dài tên cửa hàng tối đa 60 ký tự
    if (cleaned.length > 60) {
      cleaned = cleaned.substring(0, 60).trim();
    }

    return cleaned;
  }
}