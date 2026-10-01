import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/categories.dart';
import '../../../core/utils/currency_formatter.dart';

class CustomPieChart extends StatefulWidget {
  final Map<ExpenseCategory, double> data;
  final double totalAmount;

  const CustomPieChart({
    super.key,
    required this.data,
    required this.totalAmount,
  });

  @override
  State<CustomPieChart> createState() => _CustomPieChartState();
}

class _CustomPieChartState extends State<CustomPieChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(CustomPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalAmount != widget.totalAmount) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.totalAmount <= 0 || widget.data.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        child: const Text(
          'Chưa có dữ liệu chi tiêu',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(240, 240),
                painter: _PieChartPainter(
                  data: widget.data,
                  totalAmount: widget.totalAmount,
                  progress: _animation.value,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Tổng chi tiêu',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatCompact(widget.totalAmount),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.data.length} danh mục',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        // Legend Grid
        Wrap(
          spacing: 12,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: widget.data.entries.map((entry) {
            final percent = (entry.value / widget.totalAmount) * 100;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF334155), width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: entry.key.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.key.displayName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFF8FAFC),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${percent.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: entry.key.color,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final Map<ExpenseCategory, double> data;
  final double totalAmount;
  final double progress;

  _PieChartPainter({
    required this.data,
    required this.totalAmount,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (totalAmount <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 10;
    const strokeWidth = 26.0;

    // Draw background track
    final bgPaint = Paint()
      ..color = const Color(0xFF334155).withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    double startAngle = -pi / 2;
    const gapAngle = 0.04; // Visual space between slices

    for (final entry in data.entries) {
      final sweepAngle = (entry.value / totalAmount) * 2 * pi * progress;
      if (sweepAngle <= 0) continue;

      final paint = Paint()
        ..color = entry.key.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final effectiveSweep = max(0.01, sweepAngle - gapAngle);
      final effectiveStart = startAngle + (gapAngle / 2);

      final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);
      canvas.drawArc(rect, effectiveStart, effectiveSweep, false, paint);

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.totalAmount != totalAmount ||
        oldDelegate.data != data;
  }
}
