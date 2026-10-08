import 'package:flutter/material.dart';
import 'package:ocr_expense_tracker/app.dart';
import 'package:ocr_expense_tracker/features/camera/presentation/camera_screen.dart';
import 'package:ocr_expense_tracker/features/ocr/models/parsed_receipt.dart';
import 'package:ocr_expense_tracker/features/review/presentation/review_screen.dart';
import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';
import 'package:ocr_expense_tracker/features/transaction/presentation/transaction_detail_screen.dart';

/*
 * Quản lý điều hướng và tên route tập trung cho ứng dụng OCR Expense Tracker.
 *
 */
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String camera = '/camera';
  static const String review = '/review';
  static const String transactionDetail = '/transaction-detail';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const MainNavigation(),
          settings: settings,
        );
      case camera:
        return MaterialPageRoute<ParsedReceipt?>(
          builder: (_) => const CameraScreen(),
          settings: settings,
        );
      case review:
        final receipt = settings.arguments as ParsedReceipt?;
        if (receipt == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Lỗi: Không có dữ liệu biên lai')),
            ),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => ReviewScreen(parsedReceipt: receipt),
          settings: settings,
        );
      case transactionDetail:
        if (settings.arguments is Expense) {
          final expense = settings.arguments as Expense;
          return MaterialPageRoute(
            builder: (_) => TransactionDetailScreen(
              transactionId: expense.id ?? 0,
              initialExpense: expense,
            ),
            settings: settings,
          );
        } else if (settings.arguments is int) {
          final id = settings.arguments as int;
          return MaterialPageRoute(
            builder: (_) => TransactionDetailScreen(transactionId: id),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Lỗi: Không tìm thấy giao dịch')),
          ),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Không tìm thấy trang: ${settings.name}'),
            ),
          ),
          settings: settings,
        );
    }
  }
}
