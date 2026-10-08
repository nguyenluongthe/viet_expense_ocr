# CLAUDE.md

This file provides instructions for Claude Code and coding assistants working on **Viet Expense OCR** (Mini-Project 3).

## Project Overview

- **Name:** viet_expense_ocr
- **Framework:** Flutter 3.10+ / Dart 3.10+
- **Core Technology:** Google ML Kit Text Recognition (Edge OCR), Dart 3 Heuristic Regex Parser, SQLite (`sqflite`), CustomPainter Data Visualization.

## Essential Commands

```bash
# Get dependencies
flutter pub get

# Run application (Android / iOS / Desktop / Web)
flutter run

# Run automated tests (Unit & Widget tests)
flutter test

# Run code analysis & linter
flutter analyze
```

## Architecture & Code Structure

```
lib/
├── core/theme/         # AppTheme, Colors, Typography
├── core/utils/         # CurrencyFormatter, DateFormatter
├── models/             # TransactionModel, ParsedResult, MockupReceipt
├── services/           # OCRService, HeuristicParser, DatabaseService
├── views/              # Home, Scan (Sheet & Verification UI), Analytics, History
└── widgets/            # Reusable UI widgets (TransactionCard, ChartLegend)
```

## Key Development Rules

1. **Surgical Edits Only:** Do not refactor unrelated files or reformats.
2. **Offline-First:** All ML recognition and DB operations are strictly local.
3. **Vietnamese Banking Support:** Parser must reliably extract Amount (VND/đ/k), Recipient/Store, Date/Time, and Category from VietQR & Banking screens (VCB, MB, TCB, VPB, TPB, MoMo, VNPay...).
4. **Test Integrity:** Always run `flutter test` when modifying parsing regex or models.
