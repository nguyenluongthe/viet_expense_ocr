# Codebase Summary

Cấu trúc chi tiết thư mục và file mã nguồn của dự án:

```text
d:\DNT\Mini_Projiect3/
├── .agents/
│   └── skills/
│       ├── viet-expense-ocr/SKILL.md    # Hướng dẫn quy tắc & kỹ năng riêng cho dự án OCR
│       └── frontend-design/SKILL.md     # Hướng dẫn thiết kế giao diện cao cấp
├── .claude/
│   └── rules/
│       ├── development-rules.md         # Quy tắc lập trình bắt buộc
│       ├── primary-workflow.md          # Luồng làm việc 6 bước
│       ├── orchestration-protocol.md    # Giao thức phối hợp module
│       └── documentation-management.md  # Quy định quản lý tài liệu
├── .cursor/
│   └── rules/
│       └── flutter.mdc                  # Quy tắc dành cho Cursor IDE
├── docs/                                # Hệ thống tài liệu hoàn chỉnh của dự án
│   ├── README.md
│   ├── quick-start-guide.md
│   ├── system-architecture.md
│   ├── project-overview-pdr.md
│   ├── code-standards.md
│   ├── module-guides.md
│   ├── codebase-summary.md
│   └── development-roadmap.md
├── lib/
│   ├── core/
│   │   ├── theme/
│   │   │   └── app_theme.dart           # Theme màu sắc, typography Material 3
│   │   └── utils/
│   │       ├── currency_formatter.dart  # Format tiền tệ VNĐ chuẩn xác
│   │       └── date_formatter.dart      # Format ngày tháng tiếng Việt
│   ├── models/
│   │   ├── parsed_result.dart           # Dữ liệu bóc tách từ OCR
│   │   ├── transaction_model.dart       # Model giao dịch lưu SQLite
│   │   └── mockup_receipt.dart          # Dữ liệu mẫu test ngân hàng & hóa đơn
│   ├── services/
│   │   ├── ocr_service.dart             # Xử lý Google ML Kit Text Recognition
│   │   ├── heuristic_parser.dart        # Engine Regex bóc tách tiếng Việt
│   │   └── database_service.dart        # SQLite Database Manager
│   ├── views/
│   │   ├── home/
│   │   │   └── home_screen.dart         # Màn hình chính & danh sách giao dịch
│   │   ├── scan/
│   │   │   ├── scan_input_sheet.dart    # Bottom sheet chọn camera/gallery/mockup
│   │   │   └── verification_screen.dart # Màn hình xác thực & chỉnh sửa thông tin
│   │   ├── analytics/
│   │   │   └── analytics_screen.dart    # Màn hình thống kê với CustomPainter
│   │   └── history/
│   │       └── transaction_history_screen.dart # Lịch sử & bộ lọc tìm kiếm
│   ├── widgets/                         # Reusable UI widgets
│   └── main.dart                        # Entry point của ứng dụng
├── test/
│   ├── heuristic_parser_test.dart       # Unit test engine bóc tách
│   └── widget_test.dart                 # Widget test
├── AGENTS.md                            # Chỉ dẫn tổng thể cho AI Agent
├── CLAUDE.md                            # Chỉ dẫn cho Claude / Claude Code
└── analysis_options.yaml                # Quy chuẩn Lint & Static Analysis
```
