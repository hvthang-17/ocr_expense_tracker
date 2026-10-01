import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

/*
  Điểm khởi chạy ứng dụng OCR Expense Tracker.
  Khởi tạo Flutter binding và bọc toàn bộ app trong ProviderScope
  để hỗ trợ quản lý state bằng Riverpod.
*/
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: ExpenseTrackerApp(),
    ),
  );
}

