import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/transaction_model.dart';
import '../../services/database_service.dart';
import '../../widgets/summary_stat_card.dart';
import '../../widgets/transaction_card.dart';
import '../analytics/analytics_screen.dart';
import '../history/transaction_history_screen.dart';
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
    if (mounted) {
      setState(() {
        _recentTransactions = list;
        _totalSpent = total;
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
                            'Edge AI • Offline-first • Dart 3 Regex',
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
                  IconButton(
                    onPressed: _openScanModal,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Icon(Icons.add_rounded, color: AppTheme.primary),
                    ),
                  ),
                ],
              ),
            ),

            // Summary Card
            SummaryStatCard(
              totalSpent: _totalSpent,
              transactionCount: _recentTransactions.length,
              onScanTap: _openScanModal,
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
