# Viet Expense OCR Documentation

Chào mừng đến với hệ thống tài liệu chuẩn của dự án **Viet Expense OCR (Mini-Project 3)**.

## Danh mục tài liệu

- 🚀 [Hướng dẫn bắt đầu nhanh (Quick Start Guide)](quick-start-guide.md)
- 🏛️ [Kiến trúc hệ thống (System Architecture)](system-architecture.md)
- 📋 [Tổng quan sản phẩm & Yêu cầu (PDR)](project-overview-pdr.md)
- 📐 [Tiêu chuẩn mã nguồn (Code Standards)](code-standards.md)
- 🧩 [Hướng dẫn từng Module (Module Guides)](module-guides.md)
- 🗺️ [Tóm tắt mã nguồn (Codebase Summary)](codebase-summary.md)
- 🛣️ [Lộ trình phát triển (Development Roadmap)](development-roadmap.md)

## Các quy tắc cốt lõi
1. **Offline-First:** Tất cả tác vụ OCR nhận diện và lưu trữ dữ liệu đều thực hiện 100% offline trên thiết bị di động.
2. **Vietnamese Banking Optimized:** Heuristic Parser được tối ưu riêng biệt cho biên lai, VietQR và ứng dụng ngân hàng tại Việt Nam (VCB, MB, TCB, VPB, TPB, MoMo, VNPay...).
3. **Data Integrity:** Kiểm thử tự động `flutter test` đảm bảo độ chính xác của bộ bóc tách Regex.
