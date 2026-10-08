import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';

/*
 * Bảng ánh xạ từ khóa → danh mục chi tiêu tập trung.
 * Mỗi từ khóa ánh xạ tới đúng một ExpenseCategory.
 * Đây là nguồn dữ liệu duy nhất cho logic gợi ý danh mục.
 * Xem thêm: CategorySuggestionService.
 *
 * Khi văn bản OCR hoặc tên cửa hàng chứa một trong các từ khóa này
 * (không phân biệt hoa/thường), danh mục tương ứng sẽ được gợi ý.
 *
 */
final Map<String, ExpenseCategory> categoryKeywords = {
  // Ăn uống / Siêu thị / Thực phẩm
  'coffee': ExpenseCategory.food,
  'cà phê': ExpenseCategory.food,
  'cafe': ExpenseCategory.food,
  'trà sữa': ExpenseCategory.food,
  'bún': ExpenseCategory.food,
  'phở': ExpenseCategory.food,
  'cơm': ExpenseCategory.food,
  'bánh mì': ExpenseCategory.food,
  'nhà hàng': ExpenseCategory.food,
  'restaurant': ExpenseCategory.food,
  'quán ăn': ExpenseCategory.food,
  'ăn uống': ExpenseCategory.food,
  'food': ExpenseCategory.food,
  'drink': ExpenseCategory.food,
  'nước': ExpenseCategory.food,
  'kem': ExpenseCategory.food,
  'lẩu': ExpenseCategory.food,
  'gà': ExpenseCategory.food,
  'pizza': ExpenseCategory.food,
  'burger': ExpenseCategory.food,
  'milk tea': ExpenseCategory.food,
  'highlands': ExpenseCategory.food,
  'starbucks': ExpenseCategory.food,
  'jollibee': ExpenseCategory.food,
  'lotteria': ExpenseCategory.food,
  'kfc': ExpenseCategory.food,
  'circle k': ExpenseCategory.food,
  'winmart': ExpenseCategory.food,
  'lotte mart': ExpenseCategory.food,
  'co.opmart': ExpenseCategory.food,
  'coopmart': ExpenseCategory.food,
  'siêu thị': ExpenseCategory.food,
  'bách hóa': ExpenseCategory.food,
  'thịt': ExpenseCategory.food,
  'rau': ExpenseCategory.food,
  'sữa': ExpenseCategory.food,
  'bánh': ExpenseCategory.food,
  'trái cây': ExpenseCategory.food,

  // Học tập
  'sách': ExpenseCategory.study,
  'book': ExpenseCategory.study,
  'văn phòng phẩm': ExpenseCategory.study,
  'stationery': ExpenseCategory.study,
  'photocopy': ExpenseCategory.study,
  'in ấn': ExpenseCategory.study,
  'print': ExpenseCategory.study,
  'giáo trình': ExpenseCategory.study,
  'học phí': ExpenseCategory.study,
  'tuition': ExpenseCategory.study,
  'khóa học': ExpenseCategory.study,
  'course': ExpenseCategory.study,
  'fahasa': ExpenseCategory.study,
  'nhà sách': ExpenseCategory.study,
  'phương nam': ExpenseCategory.study,

  // Di chuyển
  'grab': ExpenseCategory.travel,
  'be': ExpenseCategory.travel,
  'gojek': ExpenseCategory.travel,
  'taxi': ExpenseCategory.travel,
  'xe buýt': ExpenseCategory.travel,
  'bus': ExpenseCategory.travel,
  'xăng': ExpenseCategory.travel,
  'petrol': ExpenseCategory.travel,
  'gas': ExpenseCategory.travel,
  'vé tàu': ExpenseCategory.travel,
  'vé xe': ExpenseCategory.travel,
  'parking': ExpenseCategory.travel,
  'gửi xe': ExpenseCategory.travel,
  'đỗ xe': ExpenseCategory.travel,
  'travel': ExpenseCategory.travel,
  'di chuyển': ExpenseCategory.travel,

  // Thiết bị
  'điện thoại': ExpenseCategory.gear,
  'phone': ExpenseCategory.gear,
  'laptop': ExpenseCategory.gear,
  'máy tính': ExpenseCategory.gear,
  'tai nghe': ExpenseCategory.gear,
  'headphone': ExpenseCategory.gear,
  'earphone': ExpenseCategory.gear,
  'chuột': ExpenseCategory.gear,
  'mouse': ExpenseCategory.gear,
  'bàn phím': ExpenseCategory.gear,
  'keyboard': ExpenseCategory.gear,
  'sạc': ExpenseCategory.gear,
  'charger': ExpenseCategory.gear,
  'usb': ExpenseCategory.gear,
  'adapter': ExpenseCategory.gear,
  'thế giới di động': ExpenseCategory.gear,
  'fpt shop': ExpenseCategory.gear,
  'cellphones': ExpenseCategory.gear,
  'gear': ExpenseCategory.gear,

  // Giải trí
  'phim': ExpenseCategory.entertainment,
  'movie': ExpenseCategory.entertainment,
  'cinema': ExpenseCategory.entertainment,
  'cgv': ExpenseCategory.entertainment,
  'lotte cinema': ExpenseCategory.entertainment,
  'galaxy cinema': ExpenseCategory.entertainment,
  'karaoke': ExpenseCategory.entertainment,
  'game': ExpenseCategory.entertainment,
  'bowling': ExpenseCategory.entertainment,
  'billiard': ExpenseCategory.entertainment,
  'giải trí': ExpenseCategory.entertainment,
  'entertainment': ExpenseCategory.entertainment,
  'concert': ExpenseCategory.entertainment,
  'show': ExpenseCategory.entertainment,
  'vé xem': ExpenseCategory.entertainment,
};

// Danh mục mặc định khi không có từ khóa nào khớp.
const ExpenseCategory defaultCategory = ExpenseCategory.food;
