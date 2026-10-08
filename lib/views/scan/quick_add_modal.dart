import 'package:flutter/material.dart';
import '../../core/constants/categories.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/category_item.dart';
import '../../models/transaction_model.dart';
import '../../services/database_service.dart';

class QuickAddModal extends StatefulWidget {
  const QuickAddModal({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuickAddModal(),
    );
  }

  @override
  State<QuickAddModal> createState() => _QuickAddModalState();
}

class _QuickAddModalState extends State<QuickAddModal> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  List<CategoryItem> _categories = [];
  CategoryItem? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  String _selectedPaymentMethod = 'Tiền mặt';
  bool _isLoading = true;

  final List<double> _quickAmountPresets = [10000, 20000, 35000, 50000, 100000, 200000, 500000];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final list = await DatabaseService.instance.getAllCategories();
    if (mounted) {
      setState(() {
        _categories = list;
        _selectedCategory = list.isNotEmpty ? list.first : null;
        _isLoading = false;
      });
    }
  }

  void _addQuickAmount(double amount) {
    final current = double.tryParse(_amountController.text.replaceAll('.', '').replaceAll(',', '')) ?? 0.0;
    final total = current + amount;
    setState(() {
      _amountController.text = total.toInt().toString();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    final amountText = _amountController.text.trim().replaceAll('.', '').replaceAll(',', '');
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ (> 0 VNĐ)'), backgroundColor: AppTheme.error),
      );
      return;
    }

    final title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : (_selectedCategory?.name ?? 'Chi tiêu nhanh');

    ExpenseCategory matchedEnum = ExpenseCategory.other;
    if (_selectedCategory != null) {
      matchedEnum = ExpenseCategoryExt.fromString(_selectedCategory!.name);
    }

    final transaction = TransactionModel(
      amount: amount,
      storeOrRecipient: title,
      date: _selectedDate,
      category: matchedEnum,
      note: _noteController.text.trim(),
      paymentMethod: _selectedPaymentMethod,
      rawText: 'Nhập nhanh thủ công',
    );

    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    await DatabaseService.instance.insertTransaction(transaction);

    nav.pop(true);
    messenger.showSnackBar(
      SnackBar(
        content: Text('Đã ghi nhận: ${CurrencyFormatter.formatVND(amount)} - $title'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: _isLoading
          ? const SizedBox(height: 250, child: Center(child: CircularProgressIndicator()))
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
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
                  const SizedBox(height: 12),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: AppTheme.primary, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Nhập nhanh chi tiêu (3s)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Amount Input Display
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primary.withAlpha(120), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          '₫',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            decoration: const InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 26),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_amountController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.backspace_outlined, color: AppTheme.textSecondary, size: 20),
                            onPressed: () {
                              setState(() => _amountController.clear());
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Quick Amount Chips
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _quickAmountPresets.length,
                      separatorBuilder: (c, i) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final amt = _quickAmountPresets[idx];
                        final label = amt >= 1000 ? '+${(amt / 1000).toInt()}k' : '+$amt';
                        return ActionChip(
                          label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          backgroundColor: AppTheme.cardColor,
                          side: const BorderSide(color: AppTheme.border),
                          onPressed: () => _addQuickAmount(amt),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Item Name / Note
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Tên khoản chi (VD: Bánh mì sáng, Đổ xăng, Trà sữa...)',
                      hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                      prefixIcon: const Icon(Icons.edit_note_rounded, color: AppTheme.textSecondary, size: 20),
                      filled: true,
                      fillColor: AppTheme.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Category Selector (1-Tap Chips)
                  const Text('Chọn danh mục:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (c, i) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final cat = _categories[idx];
                        final isSelected = _selectedCategory?.id == cat.id;
                        return ChoiceChip(
                          avatar: Icon(cat.icon, size: 16, color: isSelected ? Colors.white : cat.color),
                          label: Text(cat.name, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppTheme.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                          selected: isSelected,
                          selectedColor: cat.color,
                          backgroundColor: AppTheme.cardColor,
                          side: BorderSide(color: isSelected ? cat.color : AppTheme.border),
                          onSelected: (val) {
                            if (val) setState(() => _selectedCategory = cat);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Payment Method & Date Row
                  Row(
                    children: [
                      // Date Selector
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          ),
                          icon: const Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.primary),
                          label: Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Payment Method
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedPaymentMethod,
                              dropdownColor: AppTheme.surface,
                              isExpanded: true,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                              items: const [
                                DropdownMenuItem(value: 'Tiền mặt', child: Text('💵 Tiền mặt')),
                                DropdownMenuItem(value: 'QR Chuyển khoản', child: Text('📱 QR Banking')),
                                DropdownMenuItem(value: 'Ví MoMo', child: Text('👛 Ví MoMo')),
                                DropdownMenuItem(value: 'Thẻ ATM / POS', child: Text('💳 Thẻ ATM')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedPaymentMethod = val);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 3,
                      ),
                      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                      label: const Text(
                        'LƯU GIAO DỊCH NGAY (1s)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      onPressed: _saveTransaction,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
