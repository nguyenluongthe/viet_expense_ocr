# AGENTS.md

This file provides guidance to AI coding agents (Antigravity, Claude Code, Cursor, OpenCode, Codex) when working with code in this repository.

## Project Overview

**Name:** viet_expense_ocr (Mini-Project 3)  
**Type:** Flutter / Dart (Offline-first)  
**Description:** Ứng dụng quản lý chi tiêu offline-first thông minh, tự động trích xuất thông tin giao dịch từ ảnh chụp màn hình chuyển khoản ngân hàng (VietQR / Internet Banking: VCB, MBBank, Techcombank, TPBank, VPBank, MoMo...) và hóa đơn thanh toán tại Việt Nam.

## 6-Layer Architecture Overview

```
1. Hardware Input       : Camera / Photo Gallery (image_picker) & Preset Mockups
2. Edge AI (Offline OCR): google_mlkit_text_recognition (Trích xuất text thô offline)
3. Heuristic Engine     : Dart 3 Regex Engine tối ưu cho tiếng Việt & ngân hàng VN
4. Verification UI      : Màn hình đối soát, chỉnh sửa trước khi lưu
5. Local Storage        : SQLite (sqflite / sqflite_common_ffi) lưu trữ offline
6. Data Visualization   : CustomPainter (Vẽ Pie Chart & Bar Chart mượt mà)
```

## Role & Responsibilities

Your role is to analyze user requirements, adhere strictly to architectural boundaries, deliver clean code that passes `flutter test` and `flutter analyze`, and maintain documentation integrity.

## Workflows

- Primary workflow: `./.claude/rules/primary-workflow.md`
- Development rules: `./.claude/rules/development-rules.md`
- Orchestration protocols: `./.claude/rules/orchestration-protocol.md`
- Documentation management: `./.claude/rules/documentation-management.md`

**IMPORTANT:** Analyze the skills catalog in `.agents/skills/` and activate the appropriate skill for the task.  
**IMPORTANT:** Follow strictly the development rules in `./.claude/rules/development-rules.md`.  
**IMPORTANT:** Always read `./README.md` and `./docs/` before implementing architectural changes.  
**IMPORTANT:** Keep responses concise, structured, and verify success criteria.

## Development Principles

- **YAGNI**: You Aren't Gonna Need It - avoid over-engineering.
- **KISS**: Keep It Simple, Stupid - prefer straightforward, readable solutions.
- **DRY**: Don't Repeat Yourself - eliminate code duplication.
- **Karpathy Guidelines**: Think before coding, keep changes simple, edit surgically, and define verifiable success criteria.

## Non-Negotiable Coding Agent Rules

1. **Minimal focused edits only:** Touch only files and lines required for requested behavior. Never rewrite, reformat, reorder, or clean up unrelated code.
2. **Offline-First & Security:** All OCR and parsing operations must run locally on-device. Never send sensitive banking or transaction data over the internet.
3. **Regex & Heuristics Safety:** When updating `heuristic_parser.dart`, always maintain backward compatibility with existing banking formats and verify with `flutter test`.
4. **No Primitive Obsession:** Use strong Dart types, domain models (`ParsedResult`, `TransactionModel`), and enums rather than loose raw types.
5. **UI & Aesthetics Excellence:** Follow modern Flutter design patterns (custom themes, glassmorphism, responsive bottom sheets, semantic colors, smooth CustomPainter animations).
6. **Verification before completion:** Always run `flutter test` and `flutter analyze` after modifying code.

## Documentation Index

Keep documentation updated in `./docs`:
- [Project Overview & PDR](file:///d:/DNT/Mini_Projiect3/docs/project-overview-pdr.md)
- [System Architecture](file:///d:/DNT/Mini_Projiect3/docs/system-architecture.md)
- [Code Standards](file:///d:/DNT/Mini_Projiect3/docs/code-standards.md)
- [Module Guides](file:///d:/DNT/Mini_Projiect3/docs/module-guides.md)
- [Codebase Summary](file:///d:/DNT/Mini_Projiect3/docs/codebase-summary.md)
- [Development Roadmap](file:///d:/DNT/Mini_Projiect3/docs/development-roadmap.md)
- [Quick Start Guide](file:///d:/DNT/Mini_Projiect3/docs/quick-start-guide.md)
