import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';

// Dữ liệu mẫu (fixtures) mô phỏng kết quả văn bản OCR từ biên lai Việt Nam.
class OcrFixtureItem {
  final String name;
  final String rawText;
  final String expectedMerchant;
  final String expectedDate;
  final int expectedTotalAmount;
  final ExpenseCategory expectedCategory;

  const OcrFixtureItem({
    required this.name,
    required this.rawText,
    required this.expectedMerchant,
    required this.expectedDate,
    required this.expectedTotalAmount,
    required this.expectedCategory,
  });
}

class OcrFixtures {
  OcrFixtures._();

  static const List<OcrFixtureItem> allFixtures = [
    // 1. Highlands Coffee
    OcrFixtureItem(
      name: 'Highlands Coffee',
      rawText: '''
HIGHLANDS COFFEE
CH Lê Văn Sỹ - TP.HCM
HÓA ĐƠN BÁN HÀNG
Số HD: HD100293
Ngày: 15/10/2024 14:30
1x Phin Sữa Đá (L)    45.000
1x Bánh Mì Que        20.000
------------------------------
TỔNG CỘNG:            65.000 VND
Tiền mặt:            100.000
Tiền thừa:            35.000
Cảm ơn quý khách!
''',
      expectedMerchant: 'HIGHLANDS COFFEE',
      expectedDate: '2024-10-15',
      expectedTotalAmount: 65000,
      expectedCategory: ExpenseCategory.food,
    ),

    // 2. Circle K
    OcrFixtureItem(
      name: 'Circle K',
      rawText: '''
CIRCLE K VIETNAM
CH 142 Nguyễn Trãi Q1
MST: 0311293841
Ngày/Date: 20/09/2024
Mặt hàng:
1x Mì Trộn Xúc Xích   27.000
1x Coca Cola 390ml    15.000
------------------------------
THÀNH TIỀN:           42.000 đ
Thanh toán: Tiền mặt
''',
      expectedMerchant: 'CIRCLE K VIETNAM',
      expectedDate: '2024-09-20',
      expectedTotalAmount: 42000,
      expectedCategory: ExpenseCategory.food,
    ),

    // 3. WinMart+
    OcrFixtureItem(
      name: 'WinMart+',
      rawText: '''
WINMART+
ĐC: 88 Hoàng Hoa Thám, Hà Nội
SĐT: 0243.888.9999
HOÁ ĐƠN GIÁ TRỊ GIA TĂNG
Ngay: 05-11-2024
Sữa tươi Vinamilk     35.000
Trứng gà ta 10 quả    40.000
Táo Envy 1kg         110.000
------------------------------
TONG TIEN:           185.000 VND
Cảm ơn hẹn gặp lại!
''',
      expectedMerchant: 'WINMART+',
      expectedDate: '2024-11-05',
      expectedTotalAmount: 185000,
      expectedCategory: ExpenseCategory.food,
    ),

    // 4. Grab Taxi
    OcrFixtureItem(
      name: 'Grab Ride',
      rawText: '''
GRAB VIETNAM
Biên lai chuyến đi GrabCar
Mã chuyến: A-992120
Thời gian: 12/08/2024 09:15
Điểm đi: Quận 1, TP.HCM
Điểm đến: Thủ Đức, TP.HCM
------------------------------
Cước phí chuyến đi:   54.000 VND
TỔNG THANH TOÁN:      54.000 VND
Hình thức: MoMo
''',
      expectedMerchant: 'GRAB VIETNAM',
      expectedDate: '2024-08-12',
      expectedTotalAmount: 54000,
      expectedCategory: ExpenseCategory.travel,
    ),

    // 5. Phúc Long Tea & Coffee
    OcrFixtureItem(
      name: 'Phúc Long',
      rawText: '''
PHÚC LONG TEA & COFFEE
Chi nhánh Ngô Đức Kế Q1
Phiếu thanh toán
Date: 2024-07-18
1x Trà Lài Thẻn        55.000
1x Bánh Croissant      20.000
------------------------------
TOTAL:                75.000 VNĐ
Cash:                100.000
Change:               25.000
''',
      expectedMerchant: 'PHÚC LONG TEA & COFFEE',
      expectedDate: '2024-07-18',
      expectedTotalAmount: 75000,
      expectedCategory: ExpenseCategory.food,
    ),

    // 6. Nhà Sách Fahasa
    OcrFixtureItem(
      name: 'Fahasa Bookstore',
      rawText: '''
NHÀ SÁCH FAHASA
CH Fahasa Tân Bình
MST: 0300446868
Ngày: 02/06/2024
Sách Đắc Nhân Tâm     120.000
Vở kẻ ngang 200 trang   25.000
Bút chì 2B x 10        100.000
------------------------------
TỔNG CỘNG:           245.000 đ
Thanh toán thẻ ATM
''',
      expectedMerchant: 'NHÀ SÁCH FAHASA',
      expectedDate: '2024-06-02',
      expectedTotalAmount: 245000,
      expectedCategory: ExpenseCategory.study,
    ),

    // 7. CGV Cinema
    OcrFixtureItem(
      name: 'CGV Cinema',
      rawText: '''
CGV CINEMA VIETNAM
CGV Vạn Hạnh Mall
Vé xem phim / Movie Ticket
TG: 14/02/2024 19:30
Rạp 4 - Ghế H10, H11
2x Vé xem phim       220.000
------------------------------
CẦN THANH TOÁN:      220.000 VND
Cảm ơn quý khách
''',
      expectedMerchant: 'CGV CINEMA VIETNAM',
      expectedDate: '2024-02-14',
      expectedTotalAmount: 220000,
      expectedCategory: ExpenseCategory.entertainment,
    ),

    // 8. FPT Shop
    OcrFixtureItem(
      name: 'FPT Shop',
      rawText: '''
FPT SHOP
CH 261 Khánh Hội Q4
SĐT: 18006601
HÓA ĐƠN BÁN HÀNG
Ngay: 10/01/2024
Tai nghe Bluetooth Logi  890.000
------------------------------
TỔNG TIỀN:           890.000 VND
Đã thanh toán đủ
''',
      expectedMerchant: 'FPT SHOP',
      expectedDate: '2024-01-10',
      expectedTotalAmount: 890000,
      expectedCategory: ExpenseCategory.gear,
    ),

    // 9. Quán Phở Thìn
    OcrFixtureItem(
      name: 'Phở Thìn',
      rawText: '''
PHỞ THÌN HÀ NỘI
ĐC: 13 Lò Đúc, Hai Bà Trưng
Ngày: 01/12/2024
1x Phở Tái Lăn        75.000
1x Quẩy + Trứng       15.000
------------------------------
THÀNH TIỀN:           90.000 đ
Tiền mặt
''',
      expectedMerchant: 'PHỞ THÌN HÀ NỘI',
      expectedDate: '2024-12-01',
      expectedTotalAmount: 90000,
      expectedCategory: ExpenseCategory.food,
    ),

    // 10. Be Bike
    OcrFixtureItem(
      name: 'Be Ride',
      rawText: '''
BE GROUP
Hóa đơn dịch vụ BeBike
TG: 25/11/2024 18:00
Chuyến đi: Q3 -> Q7
------------------------------
CƯỚC PHÍ:             38.000 đ
TỔNG CỘNG:            38.000 đ
Thanh toán qua BePay
''',
      expectedMerchant: 'BE GROUP',
      expectedDate: '2024-11-25',
      expectedTotalAmount: 38000,
      expectedCategory: ExpenseCategory.travel,
    ),

    // 11. Starbucks Coffee
    OcrFixtureItem(
      name: 'Starbucks Coffee',
      rawText: '''
STARBUCKS COFFEE
CH New World Q1
Invoice #: 88219
Date: 30/10/2024
1x Caramel Macchiato  115.000
------------------------------
TOTAL:               115.000 VND
Paid Card
''',
      expectedMerchant: 'STARBUCKS COFFEE',
      expectedDate: '2024-10-30',
      expectedTotalAmount: 115000,
      expectedCategory: ExpenseCategory.food,
    ),

    // 12. Lotte Mart
    OcrFixtureItem(
      name: 'Lotte Mart',
      rawText: '''
LOTTE MART
Lotte Mart Nam Sài Gòn
MST: 0304741100
Ngày: 08/09/2024
Thịt heo sạch 500g    120.000
Rau củ hỗn hợp        80.000
Dầu ăn 2L            150.000
------------------------------
TỔNG THANH TOÁN:     350.000 VND
Cảm ơn quý khách!
''',
      expectedMerchant: 'LOTTE MART',
      expectedDate: '2024-09-08',
      expectedTotalAmount: 350000,
      expectedCategory: ExpenseCategory.food,
    ),

    // 13. Nhà Sách Phương Nam
    OcrFixtureItem(
      name: 'Phương Nam',
      rawText: '''
NHÀ SÁCH PHƯƠNG NAM
CH Phương Nam Vincom
Ngày: 19/05/2024
Sách Giáo Trình Anh Văn  130.000
------------------------------
TỔNG TIỀN:           130.000 đ
Tiền mặt
''',
      expectedMerchant: 'NHÀ SÁCH PHƯƠNG NAM',
      expectedDate: '2024-05-19',
      expectedTotalAmount: 130000,
      expectedCategory: ExpenseCategory.study,
    ),

    // 14. CellphoneS
    OcrFixtureItem(
      name: 'CellphoneS',
      rawText: '''
CELLPHONES
CH 136 Nguyễn Thái Học Q1
Hotline: 18002097
Ngay: 11/11/2024
Chuột máy tính không dây  450.000
------------------------------
THÀNH TIỀN:           450.000 VND
Cảm ơn quý khách đã mua hàng
''',
      expectedMerchant: 'CELLPHONES',
      expectedDate: '2024-11-11',
      expectedTotalAmount: 450000,
      expectedCategory: ExpenseCategory.gear,
    ),

    // 15. Lotte Cinema
    OcrFixtureItem(
      name: 'Lotte Cinema',
      rawText: '''
LOTTE CINEMA
Lotte Cinema Cantavil
Vé xem phim
Date: 24/12/2024
2x Cinema Ticket     180.000
------------------------------
TỔNG CỘNG:           180.000 đ
Cảm ơn quý khách
''',
      expectedMerchant: 'LOTTE CINEMA',
      expectedDate: '2024-12-24',
      expectedTotalAmount: 180000,
      expectedCategory: ExpenseCategory.entertainment,
    ),
  ];
}