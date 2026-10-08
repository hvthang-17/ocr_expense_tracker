import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/core/utils/responsive.dart';

void main() {
  group('Responsive Helper Tests', () {
    testWidgets('identifies mobile display under 600 width', (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: Builder(
            builder: (context) {
              expect(Responsive.isMobile(context), isTrue);
              expect(Responsive.isTablet(context), isFalse);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('identifies tablet display at or above 600 width', (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 1200)),
          child: Builder(
            builder: (context) {
              expect(Responsive.isMobile(context), isFalse);
              expect(Responsive.isTablet(context), isTrue);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('ResponsiveCenter constrains child width', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveCenter(
              maxWidth: 500,
              child: Text('Test Content'),
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
      final boxFinder = find.descendant(
        of: find.byType(ResponsiveCenter),
        matching: find.byType(ConstrainedBox),
      );
      final box = tester.widget<ConstrainedBox>(boxFinder);
      expect(box.constraints.maxWidth, 500);
    });
  });
}
