import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ocr_expense_tracker/core/constants/app_constants.dart';

// Lớp trợ giúp quản lý tạo, migration và kết nối cơ sở dữ liệu SQLite.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Lấy instance cơ sở dữ liệu đang hoạt động hoặc khởi tạo mới.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.databaseName);
    return _database!;
  }

  // Khởi tạo cơ sở dữ liệu với đường dẫn chỉ định.
  Future<Database> _initDB(String filePath) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, filePath);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgradeDB,
    );
  }

  // Factory constructor để test với cơ sở dữ liệu in-memory hoặc tùy chỉnh.
  static DatabaseHelper forTest(Database db) {
    final helper = DatabaseHelper._init();
    _database = db;
    return helper;
  }

  // Tạo bảng và index.
  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullable = 'TEXT';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE expenses (
        id $idType,
        merchant $textType,
        transaction_date $textType,
        total_amount $intType,
        category $textType,
        thumbnail_path $textNullable,
        created_at $textType,
        updated_at $textType
      )
    ''');

    // Index trên transaction_date để sắp xếp lịch sử và lọc theo ngày nhanh hơn
    await db.execute('''
      CREATE INDEX idx_expenses_transaction_date ON expenses(transaction_date);
    ''');

    // Index trên category để lọc và truy vấn phân tích theo danh mục
    await db.execute('''
      CREATE INDEX idx_expenses_category ON expenses(category);
    ''');
  }

  // Xử lý nâng cấp cơ sở dữ liệu an toàn.
  Future<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    // TODO: Thêm logic migration khi thay đổi schema trong tương lai
  }

  // Đóng kết nối cơ sở dữ liệu đang hoạt động.
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
