import 'package:flutter/material.dart';

enum ExpenseCategory {
  food,
  shopping,
  transport,
  utilities,
  entertainment,
  personal,
  other,
}

extension ExpenseCategoryExt on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.food:
        return 'Ăn uống & Cà phê';
      case ExpenseCategory.shopping:
        return 'Mua sắm & Siêu thị';
      case ExpenseCategory.transport:
        return 'Di chuyển & Xăng xe';
      case ExpenseCategory.utilities:
        return 'Hóa đơn & Tiện ích';
      case ExpenseCategory.entertainment:
        return 'Giải trí & Du lịch';
      case ExpenseCategory.personal:
        return 'Chuyển khoản cá nhân';
      case ExpenseCategory.other:
        return 'Chi tiêu khác';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant_rounded;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_rounded;
      case ExpenseCategory.transport:
        return Icons.directions_car_rounded;
      case ExpenseCategory.utilities:
        return Icons.receipt_long_rounded;
      case ExpenseCategory.entertainment:
        return Icons.movie_filter_rounded;
      case ExpenseCategory.personal:
        return Icons.account_balance_wallet_rounded;
      case ExpenseCategory.other:
        return Icons.category_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return const Color(0xFFFF6B6B);
      case ExpenseCategory.shopping:
        return const Color(0xFF6C5CE7);
      case ExpenseCategory.transport:
        return const Color(0xFF00CEC9);
      case ExpenseCategory.utilities:
        return const Color(0xFFFFA502);
      case ExpenseCategory.entertainment:
        return const Color(0xFFE84393);
      case ExpenseCategory.personal:
        return const Color(0xFF00B894);
      case ExpenseCategory.other:
        return const Color(0xFF636E72);
    }
  }

  static ExpenseCategory fromString(String? name) {
    if (name == null) return ExpenseCategory.other;
    return ExpenseCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == name.toLowerCase() || e.displayName.toLowerCase() == name.toLowerCase(),
      orElse: () => ExpenseCategory.other,
    );
  }
}
