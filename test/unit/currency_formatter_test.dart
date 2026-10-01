import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_expense_tracker/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    group('format', () {
      test('formats zero', () {
        expect(CurrencyFormatter.format(0), '0 VND');
      });

      test('formats small amount', () {
        expect(CurrencyFormatter.format(500), '500 VND');
      });

      test('formats thousands with separator', () {
        expect(CurrencyFormatter.format(150000), '150.000 VND');
      });

      test('formats millions', () {
        expect(CurrencyFormatter.format(1500000), '1.500.000 VND');
      });
    });

    group('formatNumber', () {
      test('formats without currency suffix', () {
        expect(CurrencyFormatter.formatNumber(150000), '150.000');
      });
    });

    group('parse', () {
      test('parses plain digits', () {
        expect(CurrencyFormatter.parse('150000'), 150000);
      });

      test('parses formatted string with comma', () {
        expect(CurrencyFormatter.parse('150,000'), 150000);
      });

      test('parses string with currency suffix', () {
        expect(CurrencyFormatter.parse('150,000 VND'), 150000);
      });

      test('parses string with dot separator', () {
        expect(CurrencyFormatter.parse('150.000'), 150000);
      });

      test('returns null for empty string', () {
        expect(CurrencyFormatter.parse(''), isNull);
      });

      test('returns null for non-digit string', () {
        expect(CurrencyFormatter.parse('abc'), isNull);
      });
    });
  });
}

