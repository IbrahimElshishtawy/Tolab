import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/models/staff_portal_models.dart';

class AnalyticsChartCard extends StatelessWidget {
  const AnalyticsChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class MiniBarChart extends StatelessWidget {
  const MiniBarChart({super.key, required this.points, required this.color});

  final List<AnalyticsPoint> points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(height: 140);
    }

    final maxValue = math.max(
      1,
      points.map((item) => item.value).reduce(math.max),
    );

    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: points.map((point) {
          final ratio = maxValue == 0 ? 0.0 : point.value / maxValue;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 16 + (ratio * 92),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.84),
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    point.label,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class MiniLineChart extends StatelessWidget {
  const MiniLineChart({super.key, required this.points, required this.color});

  final List<AnalyticsPoint> points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: CustomPaint(
        painter: _LineChartPainter(points: points, color: color),
        child: Container(),
      ),
    );
  }
}

class MiniDonutChart extends StatelessWidget {
  const MiniDonutChart({
    super.key,
    required this.items,
    required this.centerLabel,
  });

  final List<AnalyticsBreakdownItem> items;
  final String centerLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Row(
        children: [
          Expanded(
            child: CustomPaint(
              painter: _DonutPainter(items),
              child: Center(
                child: Text(
                  centerLabel,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Color(_hexToColor(item.colorHex)),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: Text(item.label)),
                          Text('${item.value.round()}%'),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.points, required this.color});

  final List<AnalyticsPoint> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) {
      return;
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final dotPaint = Paint()..color = color;
    final maxValue = points.map((item) => item.value).reduce(math.max);
    final path = Path();

    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      final dx = points.length == 1
          ? size.width / 2
          : (index / (points.length - 1)) * size.width;
      final dy =
          size.height - ((point.value / maxValue) * (size.height - 18)) - 8;
      if (index == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
      canvas.drawCircle(Offset(dx, dy), 4, dotPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.items);

  final List<AnalyticsBreakdownItem> items;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: math.min(size.width, size.height) / 2.4,
    );
    final stroke = math.min(size.width, size.height) / 8;
    final total = items.fold<double>(0, (sum, item) => sum + item.value);
    var start = -math.pi / 2;

    for (final item in items) {
      final sweep = total == 0 ? 0.0 : (item.value / total) * math.pi * 2;
      final paint = Paint()
        ..color = Color(_hexToColor(item.colorHex))
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.items != items;
  }
}

int _hexToColor(String colorHex) {
  final cleaned = colorHex.replaceAll('#', '');
  return int.parse('FF$cleaned', radix: 16);
}
