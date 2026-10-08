import 'package:flutter/material.dart';

class CategoryItem {
  final String id;
  final String name;
  final int iconCode;
  final int colorValue;
  final bool isCustom;
  final List<String> keywords;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    this.isCustom = false,
    this.keywords = const [],
  });

  IconData get icon {
    switch (id) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'study':
        return Icons.menu_book_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'rent_utilities':
        return Icons.home_work_rounded;
      case 'entertainment':
        return Icons.movie_filter_rounded;
      case 'personal':
        return Icons.account_balance_wallet_rounded;
      default:
        return _resolveIcon(iconCode);
    }
  }

  static IconData _resolveIcon(int code) {
    if (code == Icons.restaurant_rounded.codePoint) return Icons.restaurant_rounded;
    if (code == Icons.shopping_bag_rounded.codePoint) return Icons.shopping_bag_rounded;
    if (code == Icons.menu_book_rounded.codePoint) return Icons.menu_book_rounded;
    if (code == Icons.directions_car_rounded.codePoint) return Icons.directions_car_rounded;
    if (code == Icons.home_work_rounded.codePoint) return Icons.home_work_rounded;
    if (code == Icons.movie_filter_rounded.codePoint) return Icons.movie_filter_rounded;
    if (code == Icons.account_balance_wallet_rounded.codePoint) return Icons.account_balance_wallet_rounded;
    if (code == Icons.fastfood_rounded.codePoint) return Icons.fastfood_rounded;
    if (code == Icons.coffee_rounded.codePoint) return Icons.coffee_rounded;
    if (code == Icons.fitness_center_rounded.codePoint) return Icons.fitness_center_rounded;
    if (code == Icons.flight_rounded.codePoint) return Icons.flight_rounded;
    if (code == Icons.pets_rounded.codePoint) return Icons.pets_rounded;
    if (code == Icons.medical_services_rounded.codePoint) return Icons.medical_services_rounded;
    return Icons.category_rounded;
  }

  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_code': iconCode,
      'color_value': colorValue,
      'is_custom': isCustom ? 1 : 0,
      'keywords': keywords.join(','),
    };
  }

  factory CategoryItem.fromMap(Map<String, dynamic> map) {
    final kwStr = map['keywords'] as String? ?? '';
    final kwList = kwStr.isNotEmpty ? kwStr.split(',').map((e) => e.trim()).toList() : <String>[];

    return CategoryItem(
      id: map['id'] as String,
      name: map['name'] as String,
      iconCode: map['icon_code'] as int? ?? Icons.category_rounded.codePoint,
      colorValue: map['color_value'] as int? ?? 0xFF636E72,
      isCustom: (map['is_custom'] as int?) == 1,
      keywords: kwList,
    );
  }

  CategoryItem copyWith({
    String? id,
    String? name,
    int? iconCode,
    int? colorValue,
    bool? isCustom,
    List<String>? keywords,
  }) {
    return CategoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      isCustom: isCustom ?? this.isCustom,
      keywords: keywords ?? this.keywords,
    );
  }

  // Predefined default categories
  static List<CategoryItem> get defaultCategories => [
    CategoryItem(
      id: 'food',
      name: 'Ăn uống & Cà phê',
      iconCode: Icons.restaurant_rounded.codePoint,
      colorValue: 0xFFFF6B6B,
      isCustom: false,
      keywords: ['cafe', 'coffee', 'cơm', 'phở', 'bún', 'bánh mì', 'kfc', 'lotteria', 'starbucks', 'phúc long', 'quán', 'trà sữa', 'highlands', 'pizza', 'lẩu', 'gà rán'],
    ),
    CategoryItem(
      id: 'shopping',
      name: 'Mua sắm & Siêu thị',
      iconCode: Icons.shopping_bag_rounded.codePoint,
      colorValue: 0xFF6C5CE7,
      isCustom: false,
      keywords: ['shopee', 'lazada', 'tiki', 'winmart', 'coopmart', 'bách hóa xanh', 'circle k', 'gs25', '7-eleven', 'ministop', 'siêu thị', 'mall', 'chợ', 'quần áo'],
    ),
    CategoryItem(
      id: 'study',
      name: 'Học tập & Giáo trình',
      iconCode: Icons.menu_book_rounded.codePoint,
      colorValue: 0xFF0984E3,
      isCustom: false,
      keywords: ['học phí', 'sách', 'văn phòng phẩm', 'giáo trình', 'in ấn', 'photo', 'khóa học', 'tiếng anh', 'nhà sách', 'fahasa', 'tiền học'],
    ),
    CategoryItem(
      id: 'transport',
      name: 'Di chuyển & Xăng xe',
      iconCode: Icons.directions_car_rounded.codePoint,
      colorValue: 0xFF00CEC9,
      isCustom: false,
      keywords: ['grab', 'be', 'xanh sm', 'gojek', 'petrolimex', 'xăng', 'gửi xe', 'vé xe', 'bus', 'xe buýt', 'bảo dưỡng xe'],
    ),
    CategoryItem(
      id: 'rent_utilities',
      name: 'Tiền phòng & Hóa đơn',
      iconCode: Icons.home_work_rounded.codePoint,
      colorValue: 0xFFFFA502,
      isCustom: false,
      keywords: ['tiền phòng', 'tiền trọ', 'tiền nhà', 'tiền điện', 'tiền nước', 'internet', 'wifi', 'viettel', 'vnpt', 'fpt', 'truyền hình'],
    ),
    CategoryItem(
      id: 'entertainment',
      name: 'Giải trí & Du lịch',
      iconCode: Icons.movie_filter_rounded.codePoint,
      colorValue: 0xFFE84393,
      isCustom: false,
      keywords: ['cgv', 'lotte cinema', 'bhd', 'vé xem phim', 'game', 'steam', 'du lịch', 'khách sạn', 'homestay', 'billiards', 'karaoke', 'netflix', 'spotify'],
    ),
    CategoryItem(
      id: 'personal',
      name: 'Chuyển khoản cá nhân',
      iconCode: Icons.account_balance_wallet_rounded.codePoint,
      colorValue: 0xFF00B894,
      isCustom: false,
      keywords: ['chuyển tiền', 'trả tiền', 'gửi bạn', 'chia tiền', 'tiền quỹ', 'tiền mượn', 'trả nợ'],
    ),
    CategoryItem(
      id: 'other',
      name: 'Chi tiêu khác',
      iconCode: Icons.category_rounded.codePoint,
      colorValue: 0xFF636E72,
      isCustom: false,
      keywords: [],
    ),
  ];
}
