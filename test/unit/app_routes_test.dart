import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/app.dart';
import 'package:ocr_expense_tracker/core/routes/app_routes.dart';
import 'package:ocr_expense_tracker/features/camera/presentation/camera_screen.dart';
import 'package:ocr_expense_tracker/features/ocr/models/parsed_receipt.dart';
import 'package:ocr_expense_tracker/features/review/presentation/review_screen.dart';
import 'package:ocr_expense_tracker/features/transaction/models/expense.dart';
import 'package:ocr_expense_tracker/features/transaction/presentation/transaction_detail_screen.dart';

void main() {
  group('AppRoutes Unit Tests', () {
    test('home route generates MainNavigation route', () {
      const settings = RouteSettings(name: AppRoutes.home);
      final route = AppRoutes.onGenerateRoute(settings) as MaterialPageRoute?;

      expect(route, isNotNull);
      final widget = route!.builder(MockBuildContext());
      expect(widget, isA<MainNavigation>());
    });

    test('camera route generates CameraScreen route', () {
      const settings = RouteSettings(name: AppRoutes.camera);
      final route = AppRoutes.onGenerateRoute(settings) as MaterialPageRoute?;

      expect(route, isNotNull);
      expect(route, isA<MaterialPageRoute<ParsedReceipt?>>());
      final widget = route!.builder(MockBuildContext());
      expect(widget, isA<CameraScreen>());
    });

    test('review route with valid ParsedReceipt argument generates ReviewScreen route', () {
      const receipt = ParsedReceipt(
        merchant: 'Test Store',
        totalAmount: 50000,
        date: '2026-10-08',
        category: ExpenseCategory.food,
        rawText: 'Test Store 50000',
      );
      const settings = RouteSettings(name: AppRoutes.review, arguments: receipt);
      final route = AppRoutes.onGenerateRoute(settings) as MaterialPageRoute?;

      expect(route, isNotNull);
      final widget = route!.builder(MockBuildContext());
      expect(widget, isA<ReviewScreen>());
    });

    test('transactionDetail route with Expense argument generates TransactionDetailScreen route', () {
      final expense = Expense(
        id: 1,
        merchant: 'Highlands Coffee',
        transactionDate: '2026-10-08',
        totalAmount: 65000,
        category: ExpenseCategory.food,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
      final settings = RouteSettings(name: AppRoutes.transactionDetail, arguments: expense);
      final route = AppRoutes.onGenerateRoute(settings) as MaterialPageRoute?;

      expect(route, isNotNull);
      final widget = route!.builder(MockBuildContext());
      expect(widget, isA<TransactionDetailScreen>());
    });

    test('unknown route generates 404 scaffold route', () {
      const settings = RouteSettings(name: '/unknown');
      final route = AppRoutes.onGenerateRoute(settings) as MaterialPageRoute?;

      expect(route, isNotNull);
      final widget = route!.builder(MockBuildContext());
      expect(widget, isA<Scaffold>());
    });
  });
}

class MockBuildContext extends Fake implements BuildContext {}
