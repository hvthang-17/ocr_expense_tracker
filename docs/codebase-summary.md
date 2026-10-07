# Codebase Summary

## Directory Structure

```
lib/
├── main.dart                             # Application entry point
├── app.dart                              # Material app configuration & bottom navigation
├── core/
│   ├── constants/                        # App constants, category keywords
│   │   ├── app_constants.dart
│   │   └── category_keywords.dart
│   ├── theme/                            # Color scheme & Material 3 theme
│   │   └── app_theme.dart
│   ├── utils/                            # Date & VND currency formatters
│   │   ├── currency_formatter.dart
│   │   └── date_formatter.dart
│   └── widgets/                          # Shared UI components
│       ├── category_chip.dart
│       └── empty_state_widget.dart
├── features/
│   ├── camera/presentation/              # Camera screen & crop rectangle overlay
│   ├── ocr/                              # Google ML Kit service & heuristic regex parser
│   │   ├── models/parsed_receipt.dart
│   │   └── services/
│   ├── review/presentation/              # OCR result verification & editing form
│   ├── transaction/                      # Data models, SQLite database helper, repository
│   │   ├── data/
│   │   │   ├── database_helper.dart
│   │   │   └── expense_repository.dart
│   │   ├── models/expense.dart
│   │   └── presentation/
│   ├── history/presentation/             # History list view, search bar & category chips
│   └── dashboard/                        # Spending analytics & CustomPainters
│       ├── presentation/dashboard_screen.dart
│       └── painters/                     # Donut & Bar chart CustomPainters
test/
├── unit/                                 # Unit tests for formatters, models & repositories
└── widget/                               # Widget tests for Flutter screens
```
