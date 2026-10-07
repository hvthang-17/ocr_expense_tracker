---
name: frontend-design
description: Guidelines for building responsive, accessible, polished Material 3 user interfaces and custom canvas painters in Flutter.
---

# Frontend Design Guidelines

Use this skill when building or refining UI components, custom canvas drawings, animations, or layouts in Flutter.

## Design Rules for OCR Expense Tracker

1. **Material 3 Design System**: Use `Theme.of(context).colorScheme` for dynamic, accessible color tokens.
2. **Custom Canvas Painting**:
   - `DonutPainter`: Draw clean, proportional arcs with appropriate sweep angles and central summary text.
   - `BarChartPainter`: Draw rounded vertical bars with adaptive height scaling based on maximum values.
3. **Layout & Responsiveness**:
   - Use `SafeArea` on all screen root widgets.
   - Wrap input forms and scrolling feeds in `ConstrainedBox` with reasonable maximum widths for tablet/desktop preview.
   - Ensure touch targets adhere to Material 3 minimum tap area guidelines (48x48 dp).
