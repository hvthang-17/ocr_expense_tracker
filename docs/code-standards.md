# Code Standards & Best Practices

## Dart & Flutter Guidelines

- Use strict typing. Avoid `dynamic` unless interacting with unparsed JSON boundaries.
- Keep source code files under ~300 lines. Split large widgets into sub-widgets or extracted components in dedicated files.
- Store monetary values in integer (`int`) representing Vietnamese Dong (VND). E.g., `50000` = 50,000 VND.

## Riverpod State Management Rules

- Use `NotifierProvider` / `StateNotifierProvider` or `FutureProvider` for managing feature states.
- Widget-only local state (e.g. animation state, collapse/expand toggles, search text focus) should be kept in `StatefulWidget` with `setState`.
- Keep business logic inside repositories and state notifiers, away from presentation widgets.

## Clean Architecture & Layering

- **Core**: Shared utilities, formatters, Material 3 theme definitions, app constants.
- **Features**: Self-contained feature folders containing `data/`, `models/`, `presentation/`, and `services/`.
- Cross-feature code sharing must be placed in `lib/core/` or `lib/features/<feature>/models/`.

## Testing Standards

- Maintain unit test coverage for formatters (`currency_formatter_test.dart`, `date_formatter_test.dart`), repositories (`expense_repository_test.dart`), and OCR parser logic.
- Run `flutter analyze` and `flutter test` before completing any pull request or agent task.
