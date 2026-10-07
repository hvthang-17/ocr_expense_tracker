# CLAUDE.md

This file provides instructions and guidelines for Claude Code (claude.ai/code) and AI coding assistants working on the **OCR Expense Tracker** project.

## Project Context & Technology Stack

- **Framework:** Flutter (Dart ^3.13.1)
- **State Management:** Riverpod (`flutter_riverpod: ^2.5.1`)
- **Database:** SQLite (`sqflite: ^2.4.2`) with `path_provider`
- **OCR & Camera:** Google ML Kit (`google_mlkit_text_recognition: ^0.14.0`), `camera: ^0.11.1`, `image_picker`, `image`
- **Formatting:** `intl` (VND currency as `int` values, e.g. 50,000 VND)

## Karpathy Guidelines

1. **Think Before Coding:** Explicitly state assumptions, surface potential architectural trade-offs, and ask clarifying questions if requirements are ambiguous.
2. **Simplicity First:** Write the minimum code required to deliver requested behavior. Avoid speculative abstractions or unused utility code.
3. **Surgical Edits:** Touch only lines and files required for the task. Preserve existing formatting, comments, and structure of untouched code.
4. **Goal-Driven Execution:** Define explicit verification steps (e.g. static analysis, unit tests, widget tests) and execute them before reporting completion.

## Hard Development Rules

- **Strict Scope Boundaries:** Edit only the target files required for your task. Never rewrite or reformat untouched files.
- **Never Touch Unrelated Code:** Do not clean up or reorder unrelated methods/imports. Respect dirty git worktrees.
- **Integer Currency:** All transaction amounts in VND must be represented as `int` to eliminate floating-point rounding errors.
- **Riverpod Best Practices:**
  - Use `StateNotifierProvider` or `NotifierProvider` / `FutureProvider` for feature state.
  - Ephemeral widget-only state (e.g., text controller focus, animation toggles) remains local using `StatefulWidget`/`setState`.
  - Shared, asynchronous, or persistent domain state uses Riverpod providers.
  - Keep UI navigation and dialogs in the presentation layer.
- **Modularization Rule:** Keep source Dart files under 300 lines where practical. If a file grows beyond 300 lines, split logical boundaries (e.g., extracted widgets, helper functions) into separate files in the same feature folder.
- **Verification Commands:** Run `flutter analyze` and `flutter test` after code edits.

## Documentation Guidelines

Documentation is maintained in `./docs/`:
- `project-overview-pdr.md` — Scope, features, user requirements
- `system-architecture.md` — Data flows, ML Kit OCR parser pipeline, SQLite DB schema, Riverpod setup
- `code-standards.md` — Coding conventions, Riverpod guidelines, money handling rules
- `codebase-summary.md` — Directory structure & file directory map
- `design-guidelines.md` — Material 3 theme, CustomPainter chart specifications
- `agent-workflow.md` — Standard operating procedures for AI agents

**IMPORTANT:** Always read `README.md` and relevant `./docs/` files before making architectural or structural changes.
