import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';

class CustomBarChart extends StatefulWidget {
  final List<Map<String, dynamic>> dailyData;

  const CustomBarChart({
    super.key,
    required this.dailyData,
  });

  @override
  State<CustomBarChart> createState() => _CustomBarChartState();
}

class _CustomBarChartState extends State<CustomBarChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart);
    _controller.forward();
  }

  @override
  void didUpdateWidget(CustomBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dailyData.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('Chưa có dữ liệu tuần này', style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    double maxVal = 0;
    for (final item in widget.dailyData) {
      final amount = item['amount'] as double;
      if (amount > maxVal) maxVal = amount;
    }
    if (maxVal == 0) maxVal = 100000; // Default ceiling

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Chi tiêu 7 ngày qua',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withAlpha(40),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Cao nhất: ${CurrencyFormatter.formatCompact(maxVal)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 190,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(double.infinity, 190),
                painter: _BarChartPainter(
                  dailyData: widget.dailyData,
                  maxVal: maxVal,
                  progress: _animation.value,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> dailyData;
  final double maxVal;
  final double progress;

  _BarChartPainter({
    required this.dailyData,
    required this.maxVal,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const bottomPadding = 30.0;
    const topPadding = 20.0;
    final chartHeight = size.height - bottomPadding - topPadding;
    final n = dailyData.length;
    if (n == 0) return;

    final barWidth = min(28.0, (size.width / n) * 0.45);
    final slotWidth = size.width / n;

    // Draw background guide lines
    final linePaint = Paint()
      ..color = const Color(0xFF334155).withAlpha(120)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= 3; i++) {
      final y = topPadding + chartHeight * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Text Painter for labels
    final labelStyle = const TextStyle(
      color: Color(0xFF94A3B8),
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );

    final valueStyle = const TextStyle(
      color: Color(0xFFF8FAFC),
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );

    for (int i = 0; i < n; i++) {
      final item = dailyData[i];
      final amount = item['amount'] as double;
      final date = item['date'] as DateTime;
      final isMax = amount > 0 && amount == maxVal;

      final centerX = (i * slotWidth) + (slotWidth / 2);
      final left = centerX - (barWidth / 2);
      final right = centerX + (barWidth / 2);

      final barHeight = (amount / maxVal) * chartHeight * progress;
      final bottom = topPadding + chartHeight;
      final top = bottom - barHeight;

      // Draw Bar Background slot
      final slotPaint = Paint()
        ..color = const Color(0xFF1E293B)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(left, topPadding, right, bottom),
          const Radius.circular(8),
        ),
        slotPaint,
      );

      if (barHeight > 0) {
        // Bar Gradient
        final rect = Rect.fromLTRB(left, top, right, bottom);
        final gradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isMax
              ? [const Color(0xFF10B981), const Color(0xFF059669)]
              : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
        );

        final barPaint = Paint()
          ..shader = gradient.createShader(rect)
          ..style = PaintingStyle.fill;

        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(8)),
          barPaint,
        );

        // Highlight top cap glow
        if (isMax) {
          final glowPaint = Paint()
            ..color = const Color(0xFF34D399)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(8)),
            glowPaint,
          );
        }

        // Draw value above bar if large enough
        if (amount > 0 && progress > 0.8) {
          final tpVal = TextPainter(
            text: TextSpan(text: CurrencyFormatter.formatCompact(amount), style: valueStyle),
            textDirection: TextDirection.ltr,
          )..layout();
          tpVal.paint(canvas, Offset(centerX - (tpVal.width / 2), max(0, top - 16)));
        }
      }

      // Draw Day label below
      final dayLabel = DateFormatter.formatShortDay(date);
      final tpLabel = TextPainter(
        text: TextSpan(text: dayLabel, style: isMax ? labelStyle.copyWith(color: const Color(0xFF10B981), fontWeight: FontWeight.bold) : labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tpLabel.paint(canvas, Offset(centerX - (tpLabel.width / 2), bottom + 8));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.maxVal != maxVal ||
        oldDelegate.dailyData != dailyData;
  }
}
