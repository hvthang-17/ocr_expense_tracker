# Design Guidelines & Design System

## Theme & Color System

The application uses Material 3 design system rules tuned for expense tracking readability:
- **Primary Color**: Deep Emerald Green (`#0F5257` / `#006A60`) for trust, finance, and clarity.
- **Secondary / Accent**: Warm Amber / Coral for highlighted actions, totals, and call-to-actions.
- **Surface & Background**: High contrast light background with soft card elevation.

## Custom Painter Charts

1. **Donut Spending Chart (`DonutPainter`)**:
   - Renders category spending distribution with distinct category color swatches.
   - Includes central text showing overall sum in formatted VND.
2. **Weekly Spending Bar Chart (`BarChartPainter`)**:
   - Vertical bar chart displaying daily expense volume over the past week.
   - Smoothly rounded top bar corners and adaptive vertical scaling.

## Adaptive & Accessible Layouts

- Root screens wrap body content inside `SafeArea`.
- Interactive elements adhere to minimum touch dimensions (48x48 dp).
- Support dynamic text scaling via `MediaQuery`.
