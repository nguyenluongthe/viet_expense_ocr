# Development Roadmap

Kế hoạch và tiến độ phát triển của **Viet Expense OCR**:

## Giai đoạn 1: Xây dựng nền tảng cốt lõi (Đã hoàn thành ✅)
- [x] Thiết lập kiến trúc 6 tầng (6-Layer Architecture).
- [x] Tích hợp Google ML Kit Offline Text Recognition.
- [x] Phát triển `HeuristicParser` với biểu thức Regex hỗ trợ các ngân hàng phổ biến (VCB, MBBank, Techcombank, TPBank, VPBank, MoMo...).
- [x] Thiết lập SQLite Database Service lưu trữ offline.
- [x] Xây dựng UI Verification, Home, History và Analytics (CustomPainter Chart).
- [x] Đạt 100% tỷ lệ pass các Unit Test bóc tách biên lai.

## Giai đoạn 2: Tích hợp Hệ thống Agentic AI (Đang hoàn thành 🚀)
- [x] Thiết lập `AGENTS.md` và `CLAUDE.md`.
- [x] Xây dựng bộ quy tắc `.claude/rules/` và `.cursor/rules/`.
- [x] Thiết lập kỹ năng `.agents/skills/viet-expense-ocr` và `frontend-design`.
- [x] Hoàn thiện hệ thống tài liệu chuẩn `docs/`.

## Giai đoạn 3: Mở rộng tính năng nâng cao (Kế hoạch tiếp theo 🔮)
- [ ] Bổ sung nhận diện mã QR trực tiếp trên màn hình camera (Quét Real-time VietQR).
- [ ] Xuất báo cáo chi tiêu dạng Excel / CSV / PDF.
- [ ] Tính năng ngân sách hàng tháng (Budgeting) và cảnh báo chi tiêu vượt ngưỡng.
- [ ] Hỗ trợ đa tiền tệ khi đi du lịch nước ngoài (USD, JPY, EUR sang VND).
