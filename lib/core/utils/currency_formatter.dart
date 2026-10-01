class CurrencyFormatter {
  static String formatVND(double amount) {
    final intVal = amount.round();
    final str = intVal.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    final formatted = buffer.toString();
    return intVal < 0 ? '-$formatted ₫' : '$formatted ₫';
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)} tỷ';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} tr';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return '${amount.toInt()}₫';
  }

  /// Parses strings like "65.000", "120,000", "45k", "2.5tr" to double
  static double? parseAmount(String input) {
    String clean = input.trim().toLowerCase();
    if (clean.isEmpty) return null;

    // Handle k, tr suffix
    bool isK = clean.endsWith('k') || clean.contains('k ') || clean.contains('nghìn') || clean.contains('ngàn');
    bool isTr = clean.endsWith('tr') || clean.contains('triệu');

    // Remove VND, đ, d, symbols
    clean = clean.replaceAll(RegExp(r'[^\d.,ktr]'), '');

    if (isTr) {
      clean = clean.replaceAll(RegExp(r'[tr|triệu]'), '').replaceAll(',', '.');
      final val = double.tryParse(clean);
      return val != null ? val * 1000000 : null;
    }

    if (isK) {
      clean = clean.replaceAll(RegExp(r'[k|nghìn|ngàn]'), '').replaceAll(',', '.');
      final val = double.tryParse(clean);
      return val != null ? val * 1000 : null;
    }

    // Standard Vietnamese format: 65.000 or 65,000
    if (clean.contains('.') && clean.contains(',')) {
      clean = clean.replaceAll('.', '').replaceAll(',', '.');
    } else if (clean.contains('.')) {
      final parts = clean.split('.');
      if (parts.length > 2 || (parts.length == 2 && parts.last.length == 3)) {
        clean = clean.replaceAll('.', '');
      }
    } else if (clean.contains(',')) {
      final parts = clean.split(',');
      if (parts.length > 2 || (parts.length == 2 && parts.last.length == 3)) {
        clean = clean.replaceAll(',', '');
      }
    }

    return double.tryParse(clean);
  }
}
