# Quick Start Guide

Hướng dẫn thiết lập và chạy dự án **Viet Expense OCR** trên máy tính cá nhân.

## 1. Yêu cầu hệ thống
- Flutter SDK: `>= 3.10.4`
- Dart SDK: `>= 3.10.4`
- Android Studio / VS Code / Antigravity IDE
- Thiết bị thử nghiệm: Điện thoại Android/iOS thật (khuyến nghị cho tính năng Camera & ML Kit) hoặc Emulator/Simulator/Desktop.

## 2. Cài đặt môi trường & Thư viện
Mở terminal tại thư mục gốc của dự án và chạy:
```bash
flutter pub get
```

## 3. Chạy ứng dụng
```bash
# Chạy trên thiết bị mặc định
flutter run

# Hoặc chỉ định thiết bị (Android, Windows, Chrome, iOS)
flutter run -d windows
flutter run -d android
```

## 4. Chạy kiểm thử tự động
```bash
flutter test
```

## 5. Phân tích mã nguồn
```bash
flutter analyze
```
