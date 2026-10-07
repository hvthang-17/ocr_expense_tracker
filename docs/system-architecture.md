# System Architecture

## Architectural Overview

The project follows a **Feature-First Clean Architecture** pattern with decoupled presentation, domain, and data layers.

```
                  ┌────────────────────────┐
                  │   Presentation Layer   │
                  │  (Screens & Riverpod)  │
                  └───────────┬────────────┘
                              │
                              ▼
                  ┌────────────────────────┐
                  │      Domain Layer      │
                  │ (ParsedReceipt/Expense)│
                  └───────────┬────────────┘
                              │
               ┌──────────────┴──────────────┐
               ▼                             ▼
   ┌──────────────────────┐      ┌──────────────────────┐
   │    ML Kit Service    │      │  Expense Repository  │
   │  (OCR & Heuristics)  │      │   (SQLite / sqflite) │
   └──────────────────────┘      └──────────────────────┘
```

## Data Pipeline Flow

1. **Image Capture**: Camera screen captures full-resolution image and applies crop rectangle coordinates.
2. **Pre-processing**: `image` package crops and resizes image; saves a lightweight thumbnail JPEG locally.
3. **ML Kit OCR**: `InputImage.fromFilePath` passes image bytes to Google ML Kit text recognition engine on-device.
4. **Heuristic Parsing**:
   - `ReceiptParserService` receives `RecognizedText`.
   - Regex patterns search for dates (`dd/MM/yyyy`, `yyyy-MM-dd`), total amounts (`Tổng cộng`, `Thành tiền`, `TOTAL`), and merchant headers.
   - Categorizer matches keywords against `category_keywords.dart`.
5. **Review & Confirmation**: `ReviewScreen` populated with `ParsedReceipt`. User edits or confirms.
6. **Database Persistence**: `ExpenseRepository.insertExpense()` commits the record to SQLite table `expenses`.

## Database Schema (`expenses` table)

```sql
CREATE TABLE expenses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  merchant TEXT NOT NULL,
  amount INTEGER NOT NULL,          -- Amount stored in VND (integer)
  date TEXT NOT NULL,               -- ISO-8601 string (YYYY-MM-DDTHH:MM:SS)
  category TEXT NOT NULL,           -- Enum string (Food, Study, Travel, Gear, Entertainment)
  image_path TEXT,                  -- Relative or absolute path to compressed thumbnail
  notes TEXT                        -- Optional notes
);
```
