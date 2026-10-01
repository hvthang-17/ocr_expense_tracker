import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    group('toIso', () {
      test('formats date to ISO-8601 date-only', () {
        final date = DateTime(2026, 9, 12);
        expect(DateFormatter.toIso(date), '2026-09-12');
      });

      test('pads single-digit month and day', () {
        final date = DateTime(2026, 1, 5);
        expect(DateFormatter.toIso(date), '2026-01-05');
      });
    });

    group('toDisplay', () {
      test('formats date for Vietnamese display', () {
        final date = DateTime(2026, 9, 12);
        expect(DateFormatter.toDisplay(date), '12/09/2026');
      });
    });

    group('fromIso', () {
      test('parses valid ISO date', () {
        final date = DateFormatter.fromIso('2026-09-12');
        expect(date, isNotNull);
        expect(date!.year, 2026);
        expect(date.month, 9);
        expect(date.day, 12);
      });

      test('returns null for invalid format', () {
        expect(DateFormatter.fromIso('12/09/2026'), isNull);
      });

      test('returns null for empty string', () {
        expect(DateFormatter.fromIso(''), isNull);
      });

      test('returns null for invalid date', () {
        expect(DateFormatter.fromIso('2026-13-01'), isNull);
      });
    });

    group('isoToDisplay', () {
      test('converts ISO to display format', () {
        expect(DateFormatter.isoToDisplay('2026-09-12'), '12/09/2026');
      });

      test('returns original string if invalid', () {
        expect(DateFormatter.isoToDisplay('not-a-date'), 'not-a-date');
      });
    });
  });
}
