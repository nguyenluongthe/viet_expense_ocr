import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/category_item.dart';
import '../../services/database_service.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  List<CategoryItem> _categories = [];
  Map<String, int> _categoryCounts = {};
  bool _isLoading = true;

  final List<IconData> _availableIcons = [
    Icons.restaurant_rounded,
    Icons.local_cafe_rounded,
    Icons.fastfood_rounded,
    Icons.shopping_bag_rounded,
    Icons.shopping_cart_rounded,
    Icons.storefront_rounded,
    Icons.menu_book_rounded,
    Icons.school_rounded,
    Icons.edit_note_rounded,
    Icons.directions_car_rounded,
    Icons.directions_bus_rounded,
    Icons.local_gas_station_rounded,
    Icons.home_work_rounded,
    Icons.apartment_rounded,
    Icons.bolt_rounded,
    Icons.water_drop_rounded,
    Icons.movie_filter_rounded,
    Icons.sports_esports_rounded,
    Icons.flight_takeoff_rounded,
    Icons.beach_access_rounded,
    Icons.fitness_center_rounded,
    Icons.sports_soccer_rounded,
    Icons.pets_rounded,
    Icons.medical_services_rounded,
    Icons.spa_rounded,
    Icons.card_giftcard_rounded,
    Icons.group_rounded,
    Icons.account_balance_rounded,
    Icons.savings_rounded,
    Icons.computer_rounded,
    Icons.phone_iphone_rounded,
    Icons.wifi_rounded,
    Icons.build_rounded,
    Icons.brush_rounded,
    Icons.favorite_rounded,
    Icons.category_rounded,
  ];

  final List<Color> _availableColors = [
    const Color(0xFFFF6B6B),
    const Color(0xFF6C5CE7),
    const Color(0xFF0984E3),
    const Color(0xFF00CEC9),
    const Color(0xFFFFA502),
    const Color(0xFFE84393),
    const Color(0xFF00B894),
    const Color(0xFF2ED573),
    const Color(0xFF1E90FF),
    const Color(0xFFA55EEA),
    const Color(0xFFFF4757),
    const Color(0xFF70A1FF),
    const Color(0xFFFF7F50),
    const Color(0xFF20BF6B),
    const Color(0xFF4B6584),
    const Color(0xFF636E72),
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    final list = await DatabaseService.instance.getAllCategories();
    final counts = <String, int>{};
    for (final c in list) {
      final count = await DatabaseService.instance.getTransactionCountForCategory(c.name);
      counts[c.id] = count;
    }

    if (mounted) {
      setState(() {
        _categories = list;
        _categoryCounts = counts;
        _isLoading = false;
      });
    }
  }

  void _showAddOrEditCategoryDialog({CategoryItem? categoryToEdit}) {
    final isEditing = categoryToEdit != null;
    final nameController = TextEditingController(text: categoryToEdit?.name ?? '');
    IconData selectedIcon = categoryToEdit?.icon ?? _availableIcons.first;
    Color selectedColor = categoryToEdit?.color ?? _availableColors.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEditing ? 'Chỉnh sửa danh mục' : 'Thêm danh mục mới',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        // Preview Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: selectedColor.withAlpha(40),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: selectedColor.withAlpha(100)),
                          ),
                          child: Row(
                            children: [
                              Icon(selectedIcon, color: selectedColor, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                nameController.text.isNotEmpty ? nameController.text : 'Xem trước',
                                style: TextStyle(
                                  color: selectedColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Category Name Field
                    const Text('Tên danh mục', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: Tiền phòng trọ, Quỹ lớp, Gym...',
                        hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                        filled: true,
                        fillColor: AppTheme.background,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Color Picker
                    const Text('Chọn màu đại diện', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _availableColors.length,
                        separatorBuilder: (c, i) => const SizedBox(width: 10),
                        itemBuilder: (context, idx) {
                          final color = _availableColors[idx];
                          final isSelected = selectedColor.toARGB32() == color.toARGB32();
                          return GestureDetector(
                            onTap: () => setModalState(() => selectedColor = color),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: 2.5,
                                ),
                                boxShadow: isSelected
                                    ? [BoxShadow(color: color.withAlpha(150), blurRadius: 8, spreadRadius: 1)]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Icon Picker
                    const Text('Chọn biểu tượng (Icon)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 8),
                    Container(
                      height: 140,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _availableIcons.length,
                        itemBuilder: (context, idx) {
                          final icon = _availableIcons[idx];
                          final isSelected = selectedIcon.codePoint == icon.codePoint;
                          return GestureDetector(
                            onTap: () => setModalState(() => selectedIcon = icon),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? selectedColor.withAlpha(50) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? selectedColor : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                icon,
                                color: isSelected ? selectedColor : AppTheme.textMuted,
                                size: 22,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                        onPressed: () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập tên danh mục')),
                            );
                            return;
                          }

                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(ctx);

                          if (isEditing) {
                            final updated = categoryToEdit.copyWith(
                              name: name,
                              iconCode: selectedIcon.codePoint,
                              colorValue: selectedColor.toARGB32(),
                            );
                            await DatabaseService.instance.updateCategory(updated);
                          } else {
                            final newCategory = CategoryItem(
                              id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                              name: name,
                              iconCode: selectedIcon.codePoint,
                              colorValue: selectedColor.toARGB32(),
                              isCustom: true,
                            );
                            await DatabaseService.instance.addCategory(newCategory);
                          }

                          navigator.pop();
                          _loadCategories();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(isEditing ? 'Đã cập nhật danh mục' : 'Đã thêm danh mục mới'),
                              backgroundColor: AppTheme.success,
                            ),
                          );
                        },
                        child: Text(
                          isEditing ? 'Cập nhật danh mục' : 'Tạo danh mục ngay',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteCategory(CategoryItem category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa danh mục', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Text(
          'Bạn có chắc chắn muốn xóa danh mục "${category.name}" không?\nCác giao dịch thuộc danh mục này vẫn sẽ được giữ an toàn.',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              await DatabaseService.instance.deleteCategory(category.id);
              _loadCategories();
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Đã xóa danh mục "${category.name}"'),
                  backgroundColor: AppTheme.error,
                ),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Tùy biến Danh mục chi tiêu',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Thêm danh mục', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showAddOrEditCategoryDialog(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCategories,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primary.withAlpha(40), AppTheme.accent.withAlpha(20)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primary.withAlpha(60)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.tune_rounded, color: AppTheme.primary, size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Cá nhân hóa các danh mục chi tiêu theo nhu cầu học tập, sinh hoạt hoặc quỹ sự kiện của bạn.',
                            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Danh mục đang sử dụng',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Categories List
                  ..._categories.map((category) {
                    final count = _categoryCounts[category.id] ?? 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          // Icon Avatar
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: category.color.withAlpha(35),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: category.color.withAlpha(80)),
                            ),
                            child: Icon(category.icon, color: category.color, size: 22),
                          ),
                          const SizedBox(width: 14),

                          // Name and Status
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      category.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (category.isCustom) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accent.withAlpha(30),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'Tự tạo',
                                          style: TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$count giao dịch đã ghi nhận',
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),

                          // Actions
                          if (category.isCustom)
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: AppTheme.textSecondary, size: 20),
                              onPressed: () => _showAddOrEditCategoryDialog(categoryToEdit: category),
                            ),
                          if (category.isCustom)
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 20),
                              onPressed: () => _confirmDeleteCategory(category),
                            ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 80), // bottom padding for FAB
                ],
              ),
            ),
    );
  }
}
