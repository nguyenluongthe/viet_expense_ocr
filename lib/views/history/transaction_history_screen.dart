import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/categories.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/csv_exporter.dart';
import '../../models/transaction_model.dart';
import '../../services/database_service.dart';
import '../../widgets/transaction_card.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  String _searchQuery = '';
  ExpenseCategory? _filterCategory;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final list = await DatabaseService.instance.getAllTransactions();
    if (mounted) {
      setState(() {
        _transactions = list;
        _isLoading = false;
      });
    }
  }

  void _showExportCsvDialog(List<TransactionModel> transactionsToExport) {
    final csvContent = CsvExporter.generateCsv(transactionsToExport);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.table_chart_rounded, color: AppTheme.primary, size: 22),
              SizedBox(width: 8),
              Text('Xuất báo cáo Excel / CSV', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Báo cáo gồm ${transactionsToExport.length} giao dịch với chuẩn mã hóa UTF-8 tiếng Việt hiển thị chuẩn trên Microsoft Excel & Google Sheets.',
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 12),
              Container(
                height: 120,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    csvContent,
                    style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ĐÓNG', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.white),
              label: const Text('SAO CHÉP CSV', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: csvContent));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã sao chép toàn bộ dữ liệu CSV vào bộ nhớ tạm!'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteItem(TransactionModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text('Xác nhận xóa giao dịch?', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: Text(
            'Xóa giao dịch ${CurrencyFormatter.formatVND(item.amount)} tại ${item.storeOrRecipient}?',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('HỦY', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('XÓA'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && item.id != null) {
      await DatabaseService.instance.deleteTransaction(item.id!);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _transactions.where((t) {
      final matchesSearch = t.storeOrRecipient.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.note.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.transactionCode.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCat = _filterCategory == null || t.category == _filterCategory;
      return matchesSearch && matchesCat;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Lịch sử giao dịch'),
        actions: [
          IconButton(
            tooltip: 'Xuất báo cáo CSV / Excel',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(Icons.table_view_rounded, color: AppTheme.accent, size: 18),
            ),
            onPressed: () => _showExportCsvDialog(filtered),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Tìm theo tên người nhận, quán, mã GD...',
                prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textMuted),
              ),
            ),
          ),

          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Tất cả'),
                  selected: _filterCategory == null,
                  onSelected: (val) => setState(() => _filterCategory = null),
                  selectedColor: AppTheme.primary,
                  backgroundColor: AppTheme.cardColor,
                  labelStyle: TextStyle(
                    color: _filterCategory == null ? Colors.white : AppTheme.textSecondary,
                    fontWeight: _filterCategory == null ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: _filterCategory == null ? AppTheme.primary : AppTheme.border,
                  ),
                ),
                const SizedBox(width: 8),
                ...ExpenseCategory.values.map((cat) {
                  final isSelected = _filterCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(cat.icon, size: 14, color: isSelected ? Colors.white : cat.color),
                      label: Text(cat.displayName),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() => _filterCategory = val ? cat : null);
                      },
                      selectedColor: cat.color,
                      backgroundColor: AppTheme.cardColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                        fontSize: 12,
                      ),
                      side: BorderSide(color: isSelected ? cat.color : AppTheme.border),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Transaction List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 56, color: AppTheme.border),
                            const SizedBox(height: 12),
                            const Text(
                              'Không tìm thấy giao dịch nào',
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        color: AppTheme.primary,
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return TransactionCard(
                              transaction: item,
                              onDelete: () => _deleteItem(item),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
