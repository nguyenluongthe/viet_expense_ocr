# Development Rules

## Principles

- **YAGNI**, **KISS**, **DRY**.
- **Karpathy Guidelines**: Think before coding, keep changes simple, edit surgically, and define verifiable success criteria.

## Non-Negotiable Rules

1. **Minimal focused edits are mandatory:** Touch only files and lines required for the requested behavior.
2. **Offline-First Data Privacy:** All OCR parsing and database operations must strictly occur on the client device. Do not leak or transmit financial data to external endpoints.
3. **No Unrelated Refactors:** Do not rewrite, reformat, reorder, or clean up unrelated code unless explicitly requested.
4. **Heuristic Engine Integrity:** Changes to `HeuristicParser` regex must preserve existing test cases and compatibility with Vietnamese banking apps (VietQR, VCB, MB, Techcombank, TPBank, VPBank, MoMo, ZaloPay).
5. **Strong Typing & Domain Models:** Avoid primitive obsession. Always map data to `ParsedResult` and `TransactionModel`.
6. **Package-First Principle:** Check and prefer well-maintained `pub.dev` packages before building custom low-level helpers.
7. **Responsive & Accessible UI:** Ensure layouts adapt smoothly to different screen widths, handle overflow safely (`SingleChildScrollView`, `Expanded`, `Flexible`), and support dark/light modes.
8. **Verification:** Always run `flutter analyze` and `flutter test` after code changes.
