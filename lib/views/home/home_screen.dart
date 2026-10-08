import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/transaction_model.dart';
import '../../services/database_service.dart';
import '../../widgets/summary_stat_card.dart';
import '../../widgets/transaction_card.dart';
import '../analytics/analytics_screen.dart';
import '../categories/category_management_screen.dart';
import '../history/transaction_history_screen.dart';
import '../scan/quick_add_modal.dart';
import '../scan/scan_input_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<TransactionModel> _recentTransactions = [];
  double _totalSpent = 0.0;
  double _monthlySpent = 0.0;
  double _monthlyBudget = 10000000.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAppAndLoadData();
  }

  Future<void> _initAppAndLoadData() async {
    setState(() => _isLoading = true);
    // Seed initial realistic Vietnamese QR transactions if first launch
    await DatabaseService.instance.seedSampleDataIfEmpty();
    await _refreshData();
  }

  Future<void> _refreshData() async {
    final list = await DatabaseService.instance.getAllTransactions();
    final total = await DatabaseService.instance.getTotalSpending();
    final monthTotal = await DatabaseService.instance.getMonthlySpending(DateTime.now());
    final budget = await DatabaseService.instance.getMonthlyBudget();
    if (mounted) {
      setState(() {
        _recentTransactions = list;
        _totalSpent = total;
        _monthlySpent = monthTotal;
        _monthlyBudget = budget;
        _isLoading = false;
      });
    }
  }

  void _openScanModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ScanInputSheet(),
    ).then((saved) {
      if (saved == true) {
        _refreshData();
      }
    });
  }

  void _openQuickAdd() {
    QuickAddModal.show(context).then((saved) {
      if (saved == true) {
        _refreshData();
      }
    });
  }

  void _openCategoryManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CategoryManagementScreen()),
    ).then((_) => _refreshData());
  }

  void _showEditBudgetDialog() {
    final controller = TextEditingController(text: _monthlyBudget.toInt().toString());
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.savings_rounded, color: AppTheme.accent, size: 22),
              SizedBox(width: 8),
              Text('Đặt hạn mức chi tiêu tháng', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nhập số tiền ngân sách tối đa bạn muốn chi tiêu trong tháng (VNĐ):',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                decoration: InputDecoration(
                  suffixText: 'VNĐ',
                  suffixStyle: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final text = controller.text.trim().replaceAll('.', '').replaceAll(',', '');
                final val = double.tryParse(text);
                if (val != null && val > 0) {
                  final messenger = ScaffoldMessenger.of(context);
                  final nav = Navigator.of(ctx);
                  await DatabaseService.instance.setMonthlyBudget(val);
                  nav.pop();
                  _refreshData();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Đã cập nhật hạn mức ngân sách tháng!'), backgroundColor: AppTheme.success),
                  );
                }
              },
              child: const Text('Lưu hạn mức', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          const AnalyticsScreen(),
          const TransactionHistoryScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppTheme.surface,
          indicatorColor: AppTheme.primary.withAlpha(50),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary);
            }
            return const TextStyle(fontSize: 12, color: AppTheme.textMuted);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) {
            setState(() => _currentIndex = idx);
            if (idx == 0) _refreshData();
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: AppTheme.textMuted),
              selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primary),
              label: 'Tổng quan',
            ),
            NavigationDestination(
              icon: Icon(Icons.pie_chart_outline_rounded, color: AppTheme.textMuted),
              selectedIcon: Icon(Icons.pie_chart_rounded, color: AppTheme.primary),
              label: 'Biểu đồ',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined, color: AppTheme.textMuted),
              selectedIcon: Icon(Icons.receipt_long_rounded, color: AppTheme.primary),
              label: 'Lịch sử',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openScanModal,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 24),
        label: const Text(
          'QUÉT GIAO DỊCH',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppTheme.primary,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Viet Expense OCR',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Edge AI • Offline-first • Cá nhân hóa',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Nhập nhanh 3s',
                        onPressed: _openQuickAdd,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF10B981).withAlpha(100)),
                          ),
                          child: const Icon(Icons.bolt_rounded, color: Color(0xFF10B981), size: 20),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        tooltip: 'Tùy biến danh mục',
                        onPressed: _openCategoryManagement,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: const Icon(Icons.tune_rounded, color: AppTheme.accent, size: 20),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        tooltip: 'Quét giao dịch',
                        onPressed: _openScanModal,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: const Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primary, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Summary Card (Monthly Budget Tracker)
            SummaryStatCard(
              totalSpent: _totalSpent,
              monthlySpent: _monthlySpent,
              monthlyBudget: _monthlyBudget,
              transactionCount: _recentTransactions.length,
              onScanTap: _openScanModal,
              onEditBudgetTap: _showEditBudgetDialog,
            ),

            // Category Quick Filter / Shortcuts
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Giao dịch gần đây',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _currentIndex = 2),
                    child: const Text(
                      'Xem tất cả',
                      style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            // Recent Transactions List
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
              )
            else if (_recentTransactions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 54, color: AppTheme.border),
                      const SizedBox(height: 12),
                      const Text(
                        'Chưa có giao dịch nào',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Bấm "Quét giao dịch" để bắt đầu nhận diện chuyển khoản!',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._recentTransactions.take(8).map((item) {
                return TransactionCard(
                  transaction: item,
                  onDelete: () async {
                    if (item.id != null) {
                      await DatabaseService.instance.deleteTransaction(item.id!);
                      _refreshData();
                    }
                  },
                );
              }),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
