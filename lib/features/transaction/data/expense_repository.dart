import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:ocr_expense_tracker/features/transaction/data/database_helper.dart';
import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';

// Repository xử lý tất cả thao tác CRUD và truy vấn cho chi tiêu.
class ExpenseRepository {
  final DatabaseHelper _dbHelper;

  ExpenseRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  // Chèn chi tiêu mới vào SQLite.
  // Trả về ID tự tăng của bản ghi đã chèn.
  Future<int> insertExpense(Expense expense) async {
    final db = await _dbHelper.database;
    final id = await db.insert('expenses', expense.toMap());
    return id;
  }

  // Cập nhật chi tiêu đã tồn tại.
  // Trả về số hàng bị ảnh hưởng (phải là 1).
  Future<int> updateExpense(Expense expense) async {
    if (expense.id == null) {
      throw ArgumentError('Cannot update expense without an ID');
    }
    final db = await _dbHelper.database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  /*
    Xóa chi tiêu theo ID và dọn dẹp file ảnh thu nhỏ nếu không còn
    bản ghi nào khác tham chiếu tới cùng đường dẫn.
    Trả về số hàng đã xóa.
  */
  Future<int> deleteExpense(int id) async {
    final db = await _dbHelper.database;

    // Lấy chi tiêu hiện tại để kiểm tra đường dẫn ảnh trước khi xóa
    final expense = await getExpenseById(id);
    final thumbnailPath = expense?.thumbnailPath;

    final deletedRows = await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );

    // Dọn dẹp file ảnh thu nhỏ nếu không còn bản ghi nào tham chiếu
    if (deletedRows > 0 && thumbnailPath != null && thumbnailPath.isNotEmpty) {
      final remainingCount = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM expenses WHERE thumbnail_path = ?',
          [thumbnailPath],
        ),
      );
      if (remainingCount == 0 || remainingCount == null) {
        try {
          final file = File(thumbnailPath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {
          // FIXME: Xử lý lỗi khi xóa file ảnh thu nhỏ
        }
      }
    }

    return deletedRows;
  }

  // Lấy một chi tiêu theo ID.
  Future<Expense?> getExpenseById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Expense.fromMap(maps.first);
    }
    return null;
  }

  // Lấy tất cả chi tiêu sắp xếp theo ngày giao dịch giảm dần.
  Future<List<Expense>> getAllExpenses() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'expenses',
      orderBy: 'transaction_date DESC, created_at DESC',
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  /*
    Tìm kiếm và lọc chi tiêu với các tham số tùy chọn.
    - query: tìm theo tên cửa hàng (LIKE, không phân biệt hoa/thường)
    - category: lọc theo danh mục
    - startDate/endDate: lọc theo khoảng ngày
  */
  Future<List<Expense>> searchAndFilterExpenses({
    String? query,
    ExpenseCategory? category,
    String? startDate,
    String? endDate,
  }) async {
    final db = await _dbHelper.database;

    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (query != null && query.trim().isNotEmpty) {
      whereClauses.add('LOWER(merchant) LIKE ?');
      whereArgs.add('%${query.trim().toLowerCase()}%');
    }

    if (category != null) {
      whereClauses.add('category = ?');
      whereArgs.add(category.name);
    }

    if (startDate != null && startDate.isNotEmpty) {
      whereClauses.add('transaction_date >= ?');
      whereArgs.add(startDate);
    }

    if (endDate != null && endDate.isNotEmpty) {
      whereClauses.add('transaction_date <= ?');
      whereArgs.add(endDate);
    }

    final whereString =
        whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final maps = await db.query(
      'expenses',
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'transaction_date DESC, created_at DESC',
    );

    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  // Lấy danh sách chi tiêu trong khoảng ngày chỉ định (bao gồm cả 2 đầu).
  Future<List<Expense>> getByDateRange(String startDate, String endDate) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'expenses',
      where: 'transaction_date >= ? AND transaction_date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'transaction_date DESC, created_at DESC',
    );
    return maps.map((map) => Expense.fromMap(map)).toList();
  }

  /*
    Lấy tổng chi tiêu nhóm theo tuần trong [numWeeks] tuần gần nhất.
    Trả về danh sách map chứa các key:
    - weekLabel (String): ví dụ 'T1', 'T2'
    - startDate (String): ngày ISO
    - endDate (String): ngày ISO
    - total (int): tổng chi tiêu dạng VND
  */
  Future<List<Map<String, dynamic>>> getWeeklyTotals({
    int numWeeks = 5,
  }) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final weeklyTotals = <Map<String, dynamic>>[];

    for (var i = numWeeks - 1; i >= 0; i--) {
      final weekEnd = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i * 7));
      final weekStart = weekEnd.subtract(const Duration(days: 6));

      final startIso = _toIsoDate(weekStart);
      final endIso = _toIsoDate(weekEnd);

      final result = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COALESCE(SUM(total_amount), 0) FROM expenses '
          'WHERE transaction_date >= ? AND transaction_date <= ?',
          [startIso, endIso],
        ),
      );

      weeklyTotals.add({
        'weekLabel': 'T${numWeeks - i}',
        'startDate': startIso,
        'endDate': endIso,
        'total': result ?? 0,
      });
    }

    return weeklyTotals;
  }

  // Định dạng DateTime sang chuỗi ngày ISO 'YYYY-MM-DD'.
  String _toIsoDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
  }

  // Lấy tổng chi tiêu phân theo từng danh mục.
  Future<Map<ExpenseCategory, int>> getCategoryTotals({
    String? startDate,
    String? endDate,
  }) async {
    final db = await _dbHelper.database;

    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (startDate != null && startDate.isNotEmpty) {
      whereClauses.add('transaction_date >= ?');
      whereArgs.add(startDate);
    }

    if (endDate != null && endDate.isNotEmpty) {
      whereClauses.add('transaction_date <= ?');
      whereArgs.add(endDate);
    }

    final whereString =
        whereClauses.isNotEmpty ? 'WHERE ${whereClauses.join(' AND ')}' : '';

    final result = await db.rawQuery('''
      SELECT category, SUM(total_amount) as total
      FROM expenses
      $whereString
      GROUP BY category
    ''', whereArgs);

    final totals = <ExpenseCategory, int>{
      for (final cat in ExpenseCategory.values) cat: 0,
    };

    for (final row in result) {
      final catName = row['category'] as String?;
      final total = (row['total'] as num?)?.toInt() ?? 0;
      if (catName != null) {
        final cat = ExpenseCategory.fromString(catName);
        totals[cat] = total;
      }
    }

    return totals;
  }
}
