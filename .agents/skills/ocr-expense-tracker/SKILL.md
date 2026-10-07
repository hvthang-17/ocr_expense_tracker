---
name: ocr-expense-tracker
description: Core domain rules, architecture guidelines, Riverpod state management patterns, SQLite schema conventions, ML Kit OCR parsing, and custom painter standards for the OCR Expense Tracker app.
---

# OCR Expense Tracker Domain Skill

Use this skill when implementing or modifying application features, database models, OCR parsers, Riverpod providers, or Flutter screens in `ocr_expense_tracker`.

## Architectural Boundaries

- **`lib/core/`**: Infrastructure, theme, global constants, category keywords, currency/date formatters, shared widgets.
- **`lib/features/camera/`**: Camera preview, photo capture, crop box overlay.
- **`lib/features/ocr/`**: Google ML Kit text recognition integration, heuristic receipt parser (`ParsedReceipt`).
- **`lib/features/review/`**: Form for reviewing and editing extracted receipt fields before saving.
- **`lib/features/transaction/`**: `Expense` model, `ExpenseCategory` enum, `DatabaseHelper` (SQLite), `ExpenseRepository`.
- **`lib/features/history/`**: Expense list view, search input, date range & category filters.
- **`lib/features/dashboard/`**: Summary cards, donut chart (`DonutPainter`), bar chart (`BarChartPainter`).

## Domain Conventions

1. **Currency Representation**: Store all monetary values as integer (`int`) in VND (e.g. `150000` for 150,000 VND). Never use floating point (`double`) for currency calculations.
2. **Category Keyword Matching**: Heuristic categorization uses `category_keywords.dart` to infer categories (`food`, `study`, `travel`, `gear`, `entertainment`).
3. **Database Versioning & Migration**: SQLite table `expenses` uses auto-increment integer ID, `merchant` TEXT, `amount` INTEGER, `date` TEXT (ISO-8601), `category` TEXT, `image_path` TEXT, `notes` TEXT.
4. **Offline First & Privacy**: Do not add remote network requests or API keys. All processing remains strictly local.

## Verification Checklist

- Run `flutter analyze` to check for lints.
- Run `flutter test` to verify unit and widget tests.
