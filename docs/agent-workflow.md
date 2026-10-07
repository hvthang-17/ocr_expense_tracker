# AI Agent Workflow SOP

Standard Operating Procedure (SOP) for AI Coding Assistants working on `ocr_expense_tracker`.

## Workflow Phases

```
┌─────────────────────────────────────────────────────────────┐
│ Phase 1: Context Gathering & Plan Formulation              │
│ - Read README.md, AGENTS.md, CLAUDE.md, and docs/          │
│ - Inspect existing target files                             │
│ - Formulate minimal surgical plan                           │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ Phase 2: Surgical Implementation                            │
│ - Touch ONLY lines and files needed for requested behavior  │
│ - Respect existing formatting & naming conventions           │
│ - Maintain file size under ~300 lines                       │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ Phase 3: Verification & Validation                          │
│ - Run `flutter analyze`                                     │
│ - Run `flutter test`                                        │
│ - Ensure zero analyzer errors or broken tests               │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ Phase 4: Documentation Maintenance                          │
│ - Update relevant docs/ if architecture or schema modified  │
│ - Provide clear summary report                              │
└─────────────────────────────────────────────────────────────┘
```
