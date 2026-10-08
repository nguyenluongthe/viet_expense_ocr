# Product Definition & Requirements (PDR)

## 1. Mục tiêu sản phẩm
**Viet Expense OCR** là ứng dụng di động quản lý chi tiêu cá nhân offline-first, giúp người dùng tiết kiệm thời gian nhập liệu thủ công bằng cách tự động nhận diện ảnh chụp màn hình chuyển khoản ngân hàng hoặc hóa đơn tại Việt Nam thông qua Edge AI OCR.

## 2. Đối tượng người dùng
- Người dùng tại Việt Nam thường xuyên thanh toán qua mã VietQR, ứng dụng ngân hàng (Vietcombank, MB Bank, Techcombank, TPBank, VPBank...), ví điện tử (MoMo, ZaloPay, VNPay).
- Người tiêu dùng muốn theo dõi chi tiêu cá nhân mà không muốn thông tin tài chính bị gửi lên máy chủ đám mây (Bảo mật & Quyền riêng tư tuyệt đối).

## 3. Các luồng tính năng chính

### Luồng 1: Nhập liệu thông minh từ OCR
1. Người dùng chọn chụp ảnh từ Camera, chọn từ Thư viện (Gallery) hoặc chọn mẫu biên lai có sẵn (Preset Mockups).
2. Hệ thống chạy Google ML Kit Text Recognition Offline để bóc tách các dòng chữ thô.
3. Hệ thống chuyển text thô qua `HeuristicParser` (Dart 3 Regex Engine) để trích xuất:
   - **Số tiền** (VND/đ/k, xử lý dấu `.` và `,`)
   - **Người nhận / Quán / Ngân hàng**
   - **Ngày giờ giao dịch**
   - **Tự động gán danh mục** (Ăn uống & Cafe, Mua sắm, Di chuyển, Hóa đơn...)
4. Chuyển sang màn hình **Verification UI** để người dùng kiểm tra lại hoặc sửa tay nếu cần.
5. Lưu bản ghi vào SQLite Database.

### Luồng 2: Quản lý & Lịch sử giao dịch
- Xem danh sách các giao dịch đã lưu theo thứ tự thời gian.
- Tìm kiếm giao dịch theo từ khóa tên người nhận/quán.
- Lọc theo danh mục chi tiêu.
- Xóa hoặc chỉnh sửa chi tiết giao dịch.

### Luồng 3: Thống kê & Phân tích trực quan
- Tổng quan tổng chi tiêu theo thời gian.
- Biểu đồ tròn (Pie Chart) cơ cấu chi tiêu theo danh mục (vẽ bằng CustomPainter).
- Biểu đồ cột (Bar Chart) xu hướng chi tiêu hàng ngày / hàng tuần.
