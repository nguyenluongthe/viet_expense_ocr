# Code Standards & Guidelines

Tài liệu này định nghĩa các tiêu chuẩn viết mã nguồn cho dự án **Viet Expense OCR**.

## 1. Nguyên tắc lập trình cốt lõi
- **YAGNI (You Aren't Gonna Need It):** Chỉ cài đặt những tính năng thực sự cần thiết, không tạo các lớp trừu tượng dư thừa.
- **KISS (Keep It Simple, Stupid):** Ưu tiên code rõ ràng, dễ đọc hơn là code quá phức tạp.
- **DRY (Don't Repeat Yourself):** Tái sử dụng các widget, formatter và parser logic.
- **Karpathy Guidelines:** Suy nghĩ kỹ trước khi code, sửa đổi có chủ đích và tối thiểu (surgical edits), luôn xác nhận bằng kết quả kiểm thử thực tế.

## 2. Quy tắc Dart 3 & Flutter
- **`const` Constructors:** Luôn dùng `const` cho các widget tĩnh để tối ưu render tree.
- **Pattern Matching & Records:** Tận dụng Dart 3 Records và switch expressions khi xử lý parse text hoặc phân loại danh mục.
- **Null Safety:** Không sử dụng toán tử ép kiểu không an toàn (`!`) bừa bãi. Xử lý fallback giá trị mặc định rõ ràng.
- **Type Safety:** Định nghĩa model rõ ràng với `fromJson` / `toMap` và `fromMap`.

## 3. Quản lý UI & Theme
- Sử dụng màu sắc và kiểu chữ tập trung từ `lib/core/theme/app_theme.dart`. Không hardcode mã màu hex phân tán.
- Định dạng tiền tệ VND thông qua `CurrencyFormatter.formatVND(double amount)` (`lib/core/utils/currency_formatter.dart`).
- Định dạng ngày tháng thông qua `DateFormatter` (`lib/core/utils/date_formatter.dart`).

## 4. Quy trình kiểm thử & Verification
- Luôn chạy `flutter test` trước khi hoàn tất bất kỳ thay đổi nào liên quan đến `HeuristicParser` hoặc `DatabaseService`.
- Luôn đảm bảo không có cảnh báo hoặc lỗi phân tích bằng `flutter analyze`.
