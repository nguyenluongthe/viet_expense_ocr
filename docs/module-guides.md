# Module Guides

Chi tiết các module chính trong dự án **Viet Expense OCR**:

---

## 1. Module Heuristic Parser (`lib/services/heuristic_parser.dart`)
Chịu trách nhiệm trích xuất thông tin có cấu trúc từ chuỗi text thô thu được sau OCR.

### Phương thức chính:
- `ParsedResult parse(String rawText)`: Hàm chính nhận diện và trả về đối tượng `ParsedResult`.
- `double? _parseAmount(String text)`:
  - Bắt các từ khóa: `số tiền`, `tổng cộng`, `thanh toán`, `total`, `amount`.
  - Bắt các định dạng: `65.000 VND`, `45k`, `120,000 đ`, `-85.000`.
  - Lọc bỏ số tài khoản, mã giao dịch, số điện thoại.
- `String? _parseStoreOrRecipient(String text)`:
  - Nhận diện tên đơn vị / người thụ hưởng từ các dòng chữ in hoa hoặc sau nhãn `Người nhận:`, `Tên người nhận:`, `Đơn vị thụ hưởng:`.
- `DateTime? _parseDateTime(String text)`:
  - Nhận diện các định dạng ngày: `dd/MM/yyyy`, `yyyy-MM-dd`, `dd-MM-yyyy`, kèm giờ `HH:mm:ss`.
- `String _autoCategorize(String text, String? recipient)`:
  - Phân loại danh mục dựa trên từ khóa: Ăn uống & Cafe, Mua sắm, Di chuyển, Hóa đơn & Tiện ích, Chuyển khoản cá nhân.

---

## 2. Module OCR Service (`lib/services/ocr_service.dart`)
Tích hợp Google ML Kit Offline Text Recognition.

### Phương thức:
- `Future<String> processImage(String imagePath)`: Khởi tạo `TextRecognizer`, đọc ảnh offline và trả về text đầy đủ.
- `void dispose()`: Đóng recognizer để giải phóng bộ nhớ.

---

## 3. Module Database Service (`lib/services/database_service.dart`)
Quản lý cơ sở dữ liệu SQLite thông qua `sqflite` (và `sqflite_common_ffi` cho môi trường Desktop/Test).

### Bảng dữ liệu:
- `transactions`: Lưu trữ các bản ghi chi tiêu đã xác nhận.

### Thao tác hỗ trợ:
- `insertTransaction(TransactionModel transaction)`
- `getAllTransactions()`
- `deleteTransaction(int id)`
- `updateTransaction(TransactionModel transaction)`
- `getCategoryBreakdown()`
- `getTotalSpending()`

---

## 4. Module Verification UI (`lib/views/scan/`)
- `scan_input_sheet.dart`: Bottom sheet chọn nguồn ảnh (Camera, Gallery, Preset Mockup).
- `verification_screen.dart`: Màn hình cho phép người dùng kiểm tra thông tin bóc tách, chỉnh sửa danh mục, số tiền, ngày giao dịch và bấm "Lưu giao dịch".

---

## 5. Module Analytics (`lib/views/analytics/`)
- `analytics_screen.dart`: Thống kê tổng quan chi tiêu.
- `widgets/pie_chart_painter.dart`: Tự vẽ biểu đồ hình tròn (Pie Chart) với CustomPainter.
- `widgets/bar_chart_painter.dart`: Tự vẽ biểu đồ cột (Bar Chart) với CustomPainter.
