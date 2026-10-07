# Development Rules

## Principles
- **YAGNI, KISS, DRY**
- **Karpathy Guidelines:** Think before coding, keep changes minimal, edit surgically, verify goal fulfillment.

## Non-Negotiable Rules
- **Minimal Focused Edits:** Modify only files and lines required for requested behavior.
- **Worktree Integrity:** Do not reformat, reorder, or clean up unrelated code or dirty worktrees.
- **Integer VND Money:** Represent all currency values in VND as `int`.
- **State Management:** Use Riverpod for shared/persisted state; `StatefulWidget` for local UI state.
- **Package-First Principle:** Prefer existing pub.dev packages over custom reimplementations.
- **File Modularization:** Keep source files under ~300 lines. Split distinct sub-widgets or helpers when exceeding.
- **Verification:** Run `flutter analyze` and `flutter test` after code modifications.
