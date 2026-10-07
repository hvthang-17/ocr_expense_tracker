# AGENTS.md

This file provides guidance to AI coding agents (OpenCode, Roo-Code, Cursor, Codex, Windsurf, etc.) when working with code in this repository.

## Project Overview

- **Name:** OCR Expense Tracker & Receipt Parser
- **Type:** Flutter / Dart Mobile Application
- **State Management:** Riverpod (`flutter_riverpod`)
- **Database:** SQLite (`sqflite`)
- **OCR Engine:** Google ML Kit Text Recognition (`google_mlkit_text_recognition` — on-device)
- **Description:** A privacy-first, on-device receipt scanner and expense manager for students and club treasurers. Scans paper receipts via camera/gallery, extracts merchant/date/amount using ML Kit OCR & heuristic rules, categorizes expenses, and stores data locally in SQLite.

## Role & Responsibilities

Your role is to analyze user requirements, plan surgical changes, implement robust Flutter/Riverpod code following existing architecture, verify using analyzer and test suites, and maintain complete documentation.

## Core Workflows

- **Primary Workflow:** `./.claude/rules/primary-workflow.md`
- **Development Rules:** `./.claude/rules/development-rules.md`
- **Orchestration Protocols:** `./.claude/rules/orchestration-protocol.md`
- **Documentation Management:** `./.claude/rules/documentation-management.md`

Before starting any task, read `README.md` and relevant guides in `./docs/`.

## Key Development Principles

1. **Karpathy Guidelines:**
   - **Think before coding:** State assumptions, analyze trade-offs, ask when requirements are ambiguous.
   - **Simplicity first:** Implement the minimal code that solves the requested behavior. No over-engineering.
   - **Surgical changes:** Touch only necessary lines and files. Match existing codebase style. Clean up your own temporary code.
   - **Goal-driven execution:** Define clear success criteria and verify with tests and static analysis (`flutter analyze`, `flutter test`).

2. **Core Architectural Principles:**
   - **YAGNI** (You Aren't Gonna Need It): Avoid premature optimizations or unnecessary abstractions.
   - **KISS** (Keep It Simple, Stupid): Prefer readable, straightforward implementations.
   - **DRY** (Don't Repeat Yourself): Maintain single sources of truth.

3. **Non-Negotiable Coding Rules:**
   - **Minimal Edits:** Modify only files and lines directly required for the task.
   - **Worktree Respect:** Never clean up, reformat, or reorder unrelated code. Respect dirty git worktrees.
   - **No Primitive Obsession:** Use strong domain models, enums (`ExpenseCategory`), and typed value objects. Store currency in integer VND (`int`) to prevent floating-point inaccuracies.
   - **Package-First Principle:** Prefer well-maintained pub.dev packages over custom reinvented utilities. Document exceptions if custom code is required.
   - **File Modularization:** Keep source code files under ~300 lines when practical. Split into logical sub-modules when exceeding this length without breaking Clean Architecture layer boundaries.
   - **Verification Required:** Always execute `flutter analyze` and `flutter test` after code modifications.

## Documentation Structure

All repository documentation lives in `./docs/`:

```
./docs/
├── project-overview-pdr.md    # Product description & feature specs
├── system-architecture.md     # Layered architecture, Riverpod, ML Kit, DB schema
├── code-standards.md          # Flutter & Dart conventions, Riverpod & SQLite rules
├── codebase-summary.md        # File & feature directory breakdown
├── design-guidelines.md       # Material 3 design system, CustomPainter rules
└── agent-workflow.md          # Guidelines for AI agent task execution
```

## Agent Skills Catalog

Project skills available in `.agents/skills/`, `.claude/skills/`:
- `ocr-expense-tracker`: Specialized domain skill for Flutter, Riverpod, ML Kit OCR parser, SQLite repository, and custom chart painters.
- `caveman`: Terser technical communication mode for concise progress reports.
- `frontend-design`: UX/UI design guidelines for responsive, accessible Material 3 interfaces.
