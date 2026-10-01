import 'package:flutter/material.dart';
import '../../core/constants/categories.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../services/database_service.dart';
import 'widgets/custom_bar_chart.dart';
import 'widgets/custom_pie_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  double _totalSpent = 0.0;
  Map<ExpenseCategory, double> _categoryBreakdown = {};
  List<Map<String, dynamic>> _dailySpending = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    final total = await DatabaseService.instance.getTotalSpending();
    final breakdown = await DatabaseService.instance.getCategoryBreakdown();
    final daily = await DatabaseService.instance.getDailySpending(days: 7);

    if (mounted) {
      setState(() {
        _totalSpent = total;
        _categoryBreakdown = breakdown;
        _dailySpending = daily;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Báo cáo & Thống kê'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              color: AppTheme.primary,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Pie Chart Card (CustomPainter)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withAlpha(30),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.pie_chart_rounded, size: 18, color: AppTheme.primary),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Cơ cấu chi tiêu theo danh mục',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        CustomPieChart(
                          data: _categoryBreakdown,
                          totalAmount: _totalSpent,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bar Chart Card (CustomPainter)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withAlpha(30),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.bar_chart_rounded, size: 18, color: AppTheme.accent),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Xu hướng chi tiêu trong tuần',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomBarChart(dailyData: _dailySpending),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Category Breakdown Details List
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Text(
                      'CHI TIẾT DANH MỤC',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  ..._categoryBreakdown.entries.map((e) {
                    final percent = _totalSpent > 0 ? (e.value / _totalSpent) * 100 : 0.0;
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: e.key.color.withAlpha(30),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(e.key.icon, size: 18, color: e.key.color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.key.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${percent.toStringAsFixed(1)}% tổng chi',
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.formatVND(e.value),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: e.key.color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
