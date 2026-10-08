import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/currency_formatter.dart';

class SummaryStatCard extends StatelessWidget {
  final double totalSpent;
  final double monthlySpent;
  final double monthlyBudget;
  final int transactionCount;
  final VoidCallback onScanTap;
  final VoidCallback onEditBudgetTap;

  const SummaryStatCard({
    super.key,
    required this.totalSpent,
    required this.monthlySpent,
    required this.monthlyBudget,
    required this.transactionCount,
    required this.onScanTap,
    required this.onEditBudgetTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthStr = 'Tháng ${now.month}/${now.year}';
    final remainingBudget = (monthlyBudget - monthlySpent).clamp(0.0, double.infinity);
    final percentUsed = monthlyBudget > 0 ? (monthlySpent / monthlyBudget).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = monthlySpent > monthlyBudget;

    Color progressColor = AppTheme.primary;
    if (percentUsed > 0.85 || isOverBudget) {
      progressColor = AppTheme.error;
    } else if (percentUsed > 0.65) {
      progressColor = AppTheme.warning;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A), // Navy Blue
            Color(0xFF0F172A), // Slate 900
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.accent.withAlpha(80), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withAlpha(30),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.calendar_month_rounded, color: AppTheme.primary, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    monthStr.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onEditBudgetTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tune_rounded, color: AppTheme.accent, size: 13),
                      SizedBox(width: 4),
                      Text(
                        'Hạn mức',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Monthly Expense Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đã chi tháng này',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatVND(monthlySpent),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: isOverBudget ? const Color(0xFFFF7675) : Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Còn lại: ${CurrencyFormatter.formatVND(remainingBudget)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverBudget ? AppTheme.error : AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Hạn mức: ${CurrencyFormatter.formatVND(monthlyBudget)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Budget Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentUsed,
              minHeight: 8,
              backgroundColor: Colors.white.withAlpha(20),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đã dùng ${(percentUsed * 100).toStringAsFixed(1)}% ngân sách',
                style: TextStyle(
                  fontSize: 11,
                  color: isOverBudget ? AppTheme.error : AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$transactionCount giao dịch',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          // Action Buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onScanTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.camera_enhance_rounded, size: 18),
              label: const Text(
                'QUÉT ẢNH CHUYỂN KHOẢN / HÓA ĐƠN',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
