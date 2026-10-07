# Project Overview & Product Requirements (PDR)

## Executive Summary

**OCR Expense Tracker & Receipt Parser** is an open-source, on-device mobile application built with Flutter & Dart for students and club treasurers. It simplifies tracking daily paper receipts by combining high-speed camera scanning, Google ML Kit text recognition (OCR), regex heuristic parsing, and SQLite local storage.

## Key Features

1. **Receipt Scanning & Preview**: Real-time camera preview with customizable crop rectangle, tap-to-focus, and flash controls.
2. **On-Device OCR Engine**: Text recognition using Google ML Kit (`google_mlkit_text_recognition`) — guarantees 100% offline data privacy.
3. **Smart Heuristic Parser**: Automatic extraction of merchant name, total amount (in VND), transaction date, and receipt items from raw scanned text.
4. **Automated Expense Categorization**: Instant classification into 1 of 5 expense categories (`Food`, `Study`, `Travel`, `Gear`, `Entertainment`) using keyword matching.
5. **Review & Edit Screen**: User-friendly form allowing quick verification, manual correction, and thumbnail image saving before transaction commitment.
6. **Local SQLite Storage**: Fast, zero-config local relational storage via `sqflite` with thumbnail JPEG compression.
7. **History & Advanced Search**: Filter expenses by date range, category, or search merchant strings.
8. **Visual Dashboard**: Custom visual analytics featuring category spending breakdown (Donut Chart) and weekly spending trends (Bar Chart) rendered via `CustomPainter`.

## System Requirements

- **Framework**: Flutter 3.x / Dart ^3.13.1
- **Supported Platforms**: Android (Primary SDK 21+), iOS
- **Dependencies**: `flutter_riverpod`, `camera`, `permission_handler`, `google_mlkit_text_recognition`, `sqflite`, `path_provider`, `image`, `intl`
