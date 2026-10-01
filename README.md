# OCR Expense Tracker & Receipt Parser

Ứng dụng Flutter/Dart hỗ trợ sinh viên và thủ quỹ câu lạc bộ ghi nhận chi tiêu từ hóa đơn giấy. Chụp ảnh biên lai → nhận dạng văn bản bằng Google ML Kit (on-device) → trích xuất cửa hàng, ngày, tổng tiền → kiểm tra & lưu cục bộ bằng SQLite.

## Tính năng chính

- **Quét biên lai**: Camera preview với crop overlay, flash toggle, tap-to-focus
- **OCR on-device**: Nhận dạng văn bản bằng Google ML Kit — không gửi dữ liệu lên cloud
- **Trích xuất thông tin**: Parser heuristic nhận diện tổng tiền, ngày, tên cửa hàng từ biên lai VN
- **Phân loại tự động**: Gợi ý 1 trong 5 danh mục (Food, Study, Travel, Gear, Entertainment)
- **Lưu trữ cục bộ**: SQLite qua `sqflite`, ảnh thumbnail JPEG nén
- **Lịch sử giao dịch**: Tìm kiếm theo merchant, lọc theo danh mục và khoảng ngày
- **Dashboard**: Biểu đồ donut theo danh mục và bar chart theo tuần — tự vẽ bằng `CustomPainter`

## Yêu cầu hệ thống

| Thành phần     | Version                |
|----------------|------------------------|
| Flutter        | 3.47.1 (stable)        |
| Dart           | 3.13.1                 |
| Android minSDK | 21 (Android 5.0+)      |
| iOS            | Tương thích            |

## Cài đặt & Chạy

```bash
# Clone repository
git clone <repo-url>
cd ocr_expense_tracker

# Cài dependencies
flutter pub get

# Chạy ứng dụng (Android)
flutter run

# Chạy tests
flutter test

# Phân tích code
flutter analyze

# Build release APK
flutter build apk --release
```

## Cấu trúc Project

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # App shell & navigation
├── core/
│   ├── constants/                     # App constants, category keywords
│   ├── theme/                         # Material 3 theme
│   ├── utils/                         # Currency/date formatters
│   └── widgets/                       # Shared widgets
├── features/
│   ├── camera/presentation/           # Camera & crop overlay
│   ├── ocr/
│   │   ├── models/                    # ParsedReceipt
│   │   └── services/                  # ML Kit OCR, receipt parser
│   ├── review/presentation/           # Review & edit form
│   ├── transaction/
│   │   ├── data/                      # DB helper, repository
│   │   ├── models/                    # Expense model & enum
│   │   └── presentation/             # Detail, edit screens
│   ├── history/presentation/          # History list, search, filter
│   └── dashboard/
│       ├── presentation/              # Dashboard screen
│       └── painters/                  # DonutPainter, BarChartPainter
test/
├── unit/                              # Unit tests
└── widget/                            # Widget tests
```

## Dependencies

| Package                          | Mục đích                         |
|----------------------------------|----------------------------------|
| `camera`                         | Camera preview & capture         |
| `permission_handler`             | Runtime permission management    |
| `google_mlkit_text_recognition`  | On-device OCR                    |
| `sqflite`                        | SQLite database                  |
| `path_provider`                  | App documents directory          |
| `image`                          | Crop, resize, JPEG compress      |
| `intl`                           | Currency & date formatting       |

## Nền tảng

- **Android**: Target chính — phát triển, kiểm thử và demo
- **iOS**: Project duy trì khả năng build/hỗ trợ; camera/ML Kit behavior có thể khác

## Deliverables

- [ ] APK release: [Link tải](#)
- [ ] Video demo: [Link xem](#)
- [ ] Báo cáo kỹ thuật PDF: [Link đọc](#)

## Ghi chú

- Ứng dụng xử lý hoàn toàn offline — không upload ảnh/text lên cloud
- Tổng tiền lưu dạng `int` (VND) để tránh lỗi làm tròn `double`
- Biểu đồ tự vẽ bằng `CustomPainter` — không dùng thư viện chart bên thứ ba
