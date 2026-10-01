import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ocr_expense_tracker/app.dart';

void main() {
  testWidgets('App renders MainNavigation with bottom nav',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTrackerApp());

    // Kiểm tra xem các mục trong thanh điều hướng dưới cùng có tồn tại không.
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Lịch sử'), findsOneWidget);

    // Kiểm tra nút FAB camera có hiển thị không.
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
  });

  testWidgets('Bottom nav switches between Dashboard and History',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTrackerApp());

    // Dashboard hiển thị ban đầu.
    expect(find.text('Dashboard'), findsWidgets);

    // Chuyển sang tab Lịch sử.
    await tester.tap(find.text('Lịch sử'));
    await tester.pumpAndSettle();

    // Màn hình lịch sử hiển thị.
    expect(find.text('Lịch sử giao dịch'), findsWidgets);
  });
}

