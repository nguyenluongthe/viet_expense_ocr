# Viet Expense OCR (Mini-Project 3)

Ứng dụng quản lý chi tiêu offline-first thông minh, tự động trích xuất thông tin giao dịch từ **ảnh chụp màn hình chuyển khoản ngân hàng (VietQR / Internet Banking)** và **hóa đơn thanh toán** tại Việt Nam.

---

## 🏛️ Kiến trúc 6 tầng (Full 6-Layer Architecture)

```
┌────────────────────────────────┐
│ 1. Hardware Input              │ Camera / Thư viện ảnh (image_picker) & Preset Mockups
└───────────────┬────────────────┘
                ▼
┌────────────────────────────────┐
│ 2. Edge AI (Offline OCR)       │ google_mlkit_text_recognition
└───────────────┬────────────────┘ Trích xuất các khối Text thô (Blocks, Lines) hoàn toàn Offline
                ▼
┌────────────────────────────────┐
│ 3. Heuristic Engine (Dart 3)   │ Regular Expressions (Regex) tối ưu cho thị trường Việt Nam
└───────────────┬────────────────┘ Bóc tách: Tiền (VND/đ/k), Ngày giờ, Nơi nhận (Quán/Ngân hàng), Danh mục
                ▼
┌────────────────────────────────┐
│ 4. Verification UI             │ Màn hình kiểm tra trực quan, cho phép người dùng sửa tay
└───────────────┬────────────────┘
                ▼
┌────────────────────────────────┐
│ 5. Local Storage (sqflite)     │ SQLite lưu trữ giao dịch bền vững (Offline-first)
└───────────────┬────────────────┘
                ▼
┌────────────────────────────────┐
│ 6. Data Visualization          │ CustomPainter (Vẽ biểu đồ Pie Chart & Bar Chart mượt mà)
└────────────────────────────────┘
```

---

## 🎯 Điểm mấu chốt của Heuristic Parser (Thị trường Việt Nam)
Tại Việt Nam, người dùng chuyển khoản qua **VietQR / Banking app** (Vietcombank, MB Bank, Techcombank, TPBank, VPBank, MoMo...) chiếm phần lớn:
1. **Lọc số tiền (`_parseAmount`)**:
   - Nhận diện các mẫu: `Số tiền: 65.000 VND`, `Tổng cộng: 65.000 đ`, `TOTAL: 120,000`, `Thanh toán: 45k`, `Số tiền GD: -85.000 VND`.
   - Hỗ trợ đuôi: `đ`, `d`, `VND`, `VNĐ`, `k`, `nghìn`, `tr`.
   - Xử lý dấu chấm `.` hoặc dấu phẩy `,` ngăn cách hàng nghìn.
   - Loại trừ số tài khoản ngân hàng, số điện thoại, mã hóa đơn.
2. **Nhận diện Người nhận / Quán / Ngân hàng (`_parseStoreOrRecipient`)**:
   - Nhận diện từ khóa chuyển khoản: `Người thụ hưởng`, `Tên người nhận`, `Đơn vị thụ hưởng`, `Chuyển đến`, `Đến tài khoản:`.
   - Nhận diện tên viết hoa in hoa (`NGUYEN VAN A`, `HIGHLANDS COFFEE`, `CONG TY TNHH...`).
   - Tự động phát hiện ngân hàng thụ hưởng (Vietcombank, Techcombank, MB, VPBank, TPBank, MoMo, VNPay...).
3. **Phân loại danh mục tự động (`_autoCategorize`)**:
   - Tự động gán danh mục: **Ăn uống & Cafe**, **Mua sắm**, **Di chuyển**, **Hóa đơn & Tiện ích**, **Chuyển khoản cá nhân** dựa trên ngữ cảnh OCR.

---

## 🚀 Hướng dẫn khởi chạy

### 1. Chạy trên điện thoại Android / iOS (Hỗ trợ Camera & ML Kit Offline):
```bash
flutter run
```

### 2. Chạy kiểm thử tự động (Unit Test):
```bash
flutter test
```
Tất cả 5 test cases kiểm thử bóc tách Vietcombank QR, MBBank, hóa đơn 45k, dấu chấm/phẩy đã vượt qua 100%.

---

## 📁 Cấu trúc thư mục

* `lib/core/`: Theme, Formatter tiền tệ VNĐ và Date time.
* `lib/models/`: `TransactionModel`, `ParsedResult`.
* `lib/services/`:
  * `ocr_service.dart`: Xử lý OCR Offline qua Google ML Kit.
  * `heuristic_parser.dart`: Heuristic Engine bóc tách thông minh bằng Dart 3 Regex.
  * `database_service.dart`: Quản lý SQLite offline-first (`sqflite`).
* `lib/views/`:
  * `home/`: Tổng quan & danh sách giao dịch.
  * `scan/`: Bottom sheet chọn Camera/Gallery/Preset và Màn hình Verification UI.
  * `analytics/`: Màn hình thống kê với biểu đồ **CustomPainter** (Pie & Bar chart).
  * `history/`: Lịch sử giao dịch, tìm kiếm và lọc theo danh mục.
