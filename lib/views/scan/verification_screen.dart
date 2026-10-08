import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/constants/categories.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/parsed_result.dart';
import '../../models/transaction_model.dart';
import '../../services/database_service.dart';

class VerificationScreen extends StatefulWidget {
  final ParsedResult parsedResult;
  final String? imagePath;
  final Uint8List? imageBytes;

  const VerificationScreen({
    super.key,
    required this.parsedResult,
    this.imagePath,
    this.imageBytes,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _amountController;
  late TextEditingController _storeController;
  late TextEditingController _noteController;
  late TextEditingController _txCodeController;

  late DateTime _selectedDate;
  late ExpenseCategory _selectedCategory;
  late String _selectedPaymentMethod;

  bool _isSaving = false;

  final List<String> _paymentMethods = [
    'VietQR / QR Code',
    'Chuyển khoản Banking',
    'Ví điện tử',
    'Hóa đơn giấy / POS',
  ];

  @override
  void initState() {
    super.initState();
    final res = widget.parsedResult;
    _amountController = TextEditingController(
      text: res.amount != null ? res.amount!.toInt().toString() : '',
    );
    _storeController = TextEditingController(text: res.storeOrRecipient ?? '');
    _noteController = TextEditingController(text: res.note ?? '');
    _txCodeController = TextEditingController(text: res.transactionCode ?? '');

    _selectedDate = res.date ?? DateTime.now();
    _selectedCategory = res.category;
    _selectedPaymentMethod = res.paymentMethod;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _storeController.dispose();
    _noteController.dispose();
    _txCodeController.dispose();
    super.dispose();
  }

  Widget _buildReceiptImage() {
    if (widget.imageBytes != null) {
      return Image.memory(widget.imageBytes!, fit: BoxFit.cover);
    }
    if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
      if (kIsWeb) {
        return Image.network(
          widget.imagePath!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.receipt_long_rounded, color: Colors.white70, size: 36),
          ),
        );
      } else {
        try {
          final file = File(widget.imagePath!);
          if (file.existsSync()) {
            return Image.file(file, fit: BoxFit.cover);
          }
        } catch (_) {}
      }
    }
    return const Center(
      child: Icon(Icons.receipt_long_rounded, color: Colors.white70, size: 36),
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primary,
              surface: AppTheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
        builder: (context, child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppTheme.primary,
                surface: AppTheme.surface,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      } else {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            _selectedDate.hour,
            _selectedDate.minute,
          );
        });
      }
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^\d]'), '')) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số tiền hợp lệ lớn hơn 0đ'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final transaction = TransactionModel(
      amount: amount,
      storeOrRecipient: _storeController.text.trim().isNotEmpty ? _storeController.text.trim() : 'Chưa rõ',
      date: _selectedDate,
      category: _selectedCategory,
      note: _noteController.text.trim(),
      transactionCode: _txCodeController.text.trim(),
      paymentMethod: _selectedPaymentMethod,
      imagePath: widget.imagePath,
      rawText: widget.parsedResult.rawText,
    );

    try {
      await DatabaseService.instance.insertTransaction(transaction);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Đã lưu giao dịch ${CurrencyFormatter.formatVND(amount)}!',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu dữ liệu: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showRawOcrSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
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
                  const Text(
                    'Văn bản OCR nhận diện được',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Các khối text và từ khóa mà Edge AI đã trích xuất:',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  if (widget.parsedResult.matchedTokens.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.parsedResult.matchedTokens.map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.primary.withAlpha(80)),
                          ),
                          child: Text(
                            t,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const Divider(height: 24, color: AppTheme.border),
                  ],
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: ListView(
                        controller: scrollController,
                        children: [
                          SelectableText(
                            widget.parsedResult.rawText.trim().isNotEmpty
                                ? widget.parsedResult.rawText
                                : '(Không có văn bản nào được nhận diện)',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              color: AppTheme.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final confPercent = (widget.parsedResult.confidenceScore * 100).toInt();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Kiểm tra & Xác nhận'),
        actions: [
          IconButton(
            icon: const Icon(Icons.code_rounded),
            tooltip: 'Xem văn bản gốc OCR',
            onPressed: _showRawOcrSheet,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // OCR Confidence & Detection Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withAlpha(40),
                    AppTheme.accent.withAlpha(20),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary.withAlpha(80)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(50),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome, color: AppTheme.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              confPercent > 0 ? 'Độ tin cậy OCR: $confPercent%' : 'Chế độ xem & Nhập liệu',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: confPercent >= 70
                                    ? AppTheme.success
                                    : (confPercent > 0 ? AppTheme.warning : AppTheme.accent),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                confPercent >= 70 ? 'AI Tự động' : (confPercent > 0 ? 'Cần kiểm tra' : 'Thủ công / Web'),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: confPercent >= 70 ? Colors.black : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          confPercent > 0
                              ? 'Đã tự động trích xuất ${widget.parsedResult.matchedFieldCount} trường. Bạn có thể chỉnh sửa trước khi lưu.'
                              : 'Vui lòng nhìn ảnh biên lai ở trên để kiểm tra hoặc điền nhanh số tiền & người nhận.',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (widget.imageBytes != null || (widget.imagePath != null && widget.imagePath!.isNotEmpty)) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildReceiptImage(),
                      Container(color: Colors.black38),
                      const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.photo_camera_rounded, color: Colors.white70, size: 18),
                            SizedBox(width: 6),
                            Text('Ảnh biên lai giao dịch', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // SECTION 1: Số tiền giao dịch
            const Text(
              'SỐ TIỀN THANH TOÁN (VNĐ)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
              decoration: InputDecoration(
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Text('₫', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                ),
                suffixText: 'VNĐ',
                suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                hintText: '0',
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Vui lòng nhập số tiền';
                return null;
              },
            ),

            const SizedBox(height: 18),

            // SECTION 2: Người nhận / Quán / Đơn vị thụ hưởng
            const Text(
              'NGƯỜI NHẬN / ĐƠN VỊ THỤ HƯỞNG / QUÁN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _storeController,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.storefront_rounded, color: AppTheme.accent),
                hintText: 'VD: HIGHLANDS COFFEE, NGUYEN VAN A...',
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Vui lòng nhập nơi nhận';
                return null;
              },
            ),

            const SizedBox(height: 18),

            // SECTION 3: Thời gian giao dịch
            const Text(
              'THỜI GIAN GIAO DỊCH',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: AppTheme.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        DateFormatter.formatDateTime(_selectedDate),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(Icons.edit_calendar_rounded, color: AppTheme.textSecondary, size: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // SECTION 4: Phương thức thanh toán (Việt Nam market)
            const Text(
              'HÌNH THỨC THANH TOÁN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _paymentMethods.map((method) {
                final isSelected = _selectedPaymentMethod == method;
                return ChoiceChip(
                  label: Text(method),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedPaymentMethod = method);
                  },
                  selectedColor: AppTheme.primary,
                  backgroundColor: AppTheme.cardColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppTheme.primary : AppTheme.border,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 18),

            // SECTION 5: Phân loại danh mục chi tiêu
            const Text(
              'DANH MỤC CHI TIÊU',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExpenseCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return FilterChip(
                  avatar: Icon(cat.icon, size: 16, color: isSelected ? Colors.white : cat.color),
                  label: Text(cat.displayName),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedCategory = cat);
                  },
                  selectedColor: cat.color,
                  backgroundColor: AppTheme.cardColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: isSelected ? cat.color : AppTheme.border,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 18),

            // SECTION 6: Mã giao dịch & Nội dung
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MÃ GIAO DỊCH / REF',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _txCodeController,
                        decoration: const InputDecoration(
                          hintText: 'VD: VCB192837...',
                          prefixIcon: Icon(Icons.tag_rounded, size: 18, color: AppTheme.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NỘI DUNG / LỜI NHẮN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'VD: Tiền ăn trưa, tiền cà phê...',
                    prefixIcon: Icon(Icons.notes_rounded, size: 20, color: AppTheme.textMuted),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ACTION BUTTON: Save
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveTransaction,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_rounded, size: 22),
                label: Text(
                  _isSaving ? 'ĐANG LƯU DỮ LIỆU...' : 'LƯU GIAO DỊCH VÀO HỆ THỐNG',
                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
