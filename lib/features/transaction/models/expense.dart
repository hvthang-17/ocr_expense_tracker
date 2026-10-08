import 'package:flutter/material.dart';
import 'package:ocr_expense_tracker/core/theme/app_theme.dart';

/*
 * 5 danh mục chi tiêu được ứng dụng hỗ trợ.
 * Mỗi danh mục có nhãn hiển thị, màu sắc và icon
 * để hiển thị đồng nhất trên form, danh sách, biểu đồ donut và bar chart.
 *
 */
enum ExpenseCategory {
  food,
  study,
  travel,
  gear,
  entertainment;

  // Nhãn hiển thị dễ đọc.
  String get label {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.study:
        return 'Study';
      case ExpenseCategory.travel:
        return 'Travel';
      case ExpenseCategory.gear:
        return 'Gear';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
    }
  }

  // Màu sắc đồng nhất dùng trong biểu đồ, chip và icon.
  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return AppTheme.foodColor;
      case ExpenseCategory.study:
        return AppTheme.studyColor;
      case ExpenseCategory.travel:
        return AppTheme.travelColor;
      case ExpenseCategory.gear:
        return AppTheme.gearColor;
      case ExpenseCategory.entertainment:
        return AppTheme.entertainmentColor;
    }
  }

  // Icon đại diện cho danh mục.
  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.study:
        return Icons.menu_book;
      case ExpenseCategory.travel:
        return Icons.directions_car;
      case ExpenseCategory.gear:
        return Icons.devices;
      case ExpenseCategory.entertainment:
        return Icons.movie;
    }
  }

  // Tạo từ chuỗi đã lưu trong cơ sở dữ liệu.
  static ExpenseCategory fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExpenseCategory.food,
    );
  }
}

// Model dữ liệu cho một giao dịch chi tiêu.
class Expense {
  final int? id;
  final String merchant;
  final String transactionDate; // Ngày ISO-8601 chỉ ngày: 'YYYY-MM-DD'
  final int totalAmount; // Số tiền VND dạng số nguyên
  final ExpenseCategory category;
  final String? thumbnailPath;
  final String createdAt; // Thời gian tạo ISO-8601
  final String updatedAt; // Thời gian cập nhật ISO-8601

  const Expense({
    this.id,
    required this.merchant,
    required this.transactionDate,
    required this.totalAmount,
    required this.category,
    this.thumbnailPath,
    required this.createdAt,
    required this.updatedAt,
  });

  // Tạo từ map dữ liệu của hàng trong cơ sở dữ liệu.
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      merchant: map['merchant'] as String,
      transactionDate: map['transaction_date'] as String,
      totalAmount: map['total_amount'] as int,
      category: ExpenseCategory.fromString(map['category'] as String),
      thumbnailPath: map['thumbnail_path'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  // Chuyển đổi thành map để chèn vào cơ sở dữ liệu.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'merchant': merchant,
      'transaction_date': transactionDate,
      'total_amount': totalAmount,
      'category': category.name,
      'thumbnail_path': thumbnailPath,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Tạo bản sao với các trường được ghi đè tùy chọn.
  Expense copyWith({
    int? id,
    String? merchant,
    String? transactionDate,
    int? totalAmount,
    ExpenseCategory? category,
    String? thumbnailPath,
    String? createdAt,
    String? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      transactionDate: transactionDate ?? this.transactionDate,
      totalAmount: totalAmount ?? this.totalAmount,
      category: category ?? this.category,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Expense(id: $id, merchant: $merchant, date: $transactionDate, '
        'amount: $totalAmount, category: ${category.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense &&
        other.id == id &&
        other.merchant == merchant &&
        other.transactionDate == transactionDate &&
        other.totalAmount == totalAmount &&
        other.category == category &&
        other.thumbnailPath == thumbnailPath;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      merchant,
      transactionDate,
      totalAmount,
      category,
      thumbnailPath,
    );
  }
}
