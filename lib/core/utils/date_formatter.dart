import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${formatTime(date)}';
  }

  static String formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  static String formatTime(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$h:$min';
  }

  static String formatDayOfWeek(DateTime date) {
    const days = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];
    final idx = (date.weekday - 1).clamp(0, 6);
    return '${days[idx]}, ${formatDate(date)}';
  }

  static String formatShortDay(DateTime date) {
    const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final idx = (date.weekday - 1).clamp(0, 6);
    return days[idx];
  }

  /// Parses date string found in Vietnamese receipts and banking screenshots
  static DateTime? parseVietnameseDate(String input) {
    final clean = input.trim();
    if (clean.isEmpty) return null;

    final formats = [
      'dd/MM/yyyy HH:mm:ss',
      'dd/MM/yyyy HH:mm',
      'dd/MM/yyyy',
      'dd-MM-yyyy HH:mm:ss',
      'dd-MM-yyyy HH:mm',
      'dd-MM-yyyy',
      'yyyy-MM-dd HH:mm:ss',
      'yyyy-MM-dd HH:mm',
      'yyyy-MM-dd',
      'HH:mm dd/MM/yyyy',
      'HH:mm:ss dd/MM/yyyy',
    ];

    for (final fmt in formats) {
      try {
        return DateFormat(fmt).parse(clean);
      } catch (_) {}
    }

    return null;
  }
}
