---
name: viet-expense-ocr
description: >
  Domain-specific engineering guide for Viet Expense OCR. Use when developing or debugging
  offline OCR recognition, heuristic regex parsing for Vietnamese banking apps/receipts,
  SQLite local database, verification UI, or CustomPainter analytics.
---

# Viet Expense OCR — Domain & Implementation Skill

## 1. Scope & Capabilities

Use this skill when working on:
- **Offline ML Kit OCR pipeline** (`lib/services/ocr_service.dart`).
- **Vietnamese Heuristic Regex Parser** (`lib/services/heuristic_parser.dart`): parsing VND currencies, timestamps, bank names, recipient identifiers, and category categorization.
- **SQLite Database operations** (`lib/services/database_service.dart`): schema, CRUD operations, aggregation queries.
- **Verification UI & Correction flows** (`lib/views/scan/verification_screen.dart`): visual bounding box review, manual adjustments.
- **CustomPainter Visualization** (`lib/views/analytics/`): Pie chart, bar charts, custom rendering.

## 2. Vietnamese Banking & Receipt Regex Rules

When adjusting `HeuristicParser`:

### Amount Parsing (`_parseAmount`)
- Patterns supported:
  - Explicit labels: `Số tiền: 65.000 VND`, `Tổng cộng: 65,000 đ`, `TOTAL: 120.000`
  - Slang / Shortcuts: `45k`, `45 nghìn`, `1.5tr`
  - Signed amounts: `-85.000 VND`, `+250.000 đ`
- Strict exclusion filters:
  - Account numbers (e.g., `1029384756`)
  - Phone numbers (`0987654321`, `849...`)
  - Transaction IDs (`FT240101...`, `GD9384...`)

### Recipient & Store Detection (`_parseStoreOrRecipient`)
- Detect recipient keywords: `Người thụ hưởng`, `Tên người nhận`, `Đơn vị thụ hưởng`, `Chuyển đến:`, `Đến tài khoản:`
- Match uppercase business / person names (`NGUYEN VAN A`, `HIGHLANDS COFFEE`, `THE COFFEE HOUSE`)
- Recognized Bank names: `Vietcombank`, `Techcombank`, `MB Bank`, `VPBank`, `TPBank`, `ACB`, `BIDV`, `Agribank`, `MoMo`, `ZaloPay`, `VNPay`.

### Automatic Categorization (`_autoCategorize`)
- `Ăn uống & Cafe`: highlands, coffee, phở, cơm, bánh mì, kfc, lotteria, starbucks, phúc long, gong cha, quán, nhà hàng.
- `Mua sắm`: shopee, lazada, tiki, winmart, coopmart, circle k, gs25, 7-eleven, siêu thị, mall.
- `Di chuyển`: grab, be, xanh sm, gojek, taxi, xăng, petrolimex.
- `Hóa đơn & Tiện ích`: điện, nước, internet, vnpt, viettel, fpt, học phí, viện phí.
- `Chuyển khoản cá nhân`: default for peer-to-peer bank transfers.

## 3. SQLite Schema Guidelines

Table `transactions`:
- `id` (INTEGER PRIMARY KEY AUTOINCREMENT)
- `title` (TEXT)
- `amount` (REAL)
- `date` (TEXT - ISO8601)
- `category` (TEXT)
- `raw_text` (TEXT)
- `image_path` (TEXT)
- `created_at` (TEXT)

## 4. Verification & Testing

Always ensure that all unit test cases in `test/heuristic_parser_test.dart` or `test/widget_test.dart` pass without error:
```bash
flutter test
```
