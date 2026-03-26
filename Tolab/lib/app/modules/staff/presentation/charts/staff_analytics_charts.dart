import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../models/staff_admin_models.dart';
import '../design/staff_management_tokens.dart';

class StaffChartSlice {
  const StaffChartSlice({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class StaffDonutChart extends StatelessWidget {
  const StaffDonutChart({
    super.key,
    required this.slices,
    required this.centerTitle,
    required this.centerSubtitle,
  });

  final List<StaffChartSlice> slices;
  final String centerTitle;
  final String centerSubtitle;

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<double>(0, (sum, slice) => sum + slice.value);
    final normalized = total == 0
        ? const [
            StaffChartSlice(
              label: 'No data',
              value: 1,
              color: AppColors.slateSoft,
            ),
          ]
        : slices;

    return Row(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 44,
                    startDegreeOffset: -90,
                    borderData: FlBorderData(show: false),
                    sections: [
                      for (final slice in normalized)
                        PieChartSectionData(
                          value: slice.value,
                          color: slice.color,
                          radius: 12,
                          showTitle: false,
                        ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      centerTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      centerSubtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final slice in slices)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: slice.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          slice.label,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        slice.value.toStringAsFixed(slice.value % 1 == 0 ? 0 : 1),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class StaffBarChart extends StatelessWidget {
  const StaffBarChart({
    super.key,
    required this.slices,
    required this.maxY,
  });

  final List<StaffChartSlice> slices;
  final double maxY;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: maxY <= 4 ? 1 : maxY / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: StaffManagementPalette.border(context),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= slices.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    slices[index].label,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var index = 0; index < slices.length; index++)
            BarChartGroupData(
              x: index,
              barsSpace: 8,
              barRods: [
                BarChartRodData(
                  toY: slices[index].value,
                  width: 18,
                  borderRadius: BorderRadius.circular(8),
                  color: slices[index].color,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class StaffTrendChart extends StatelessWidget {
  const StaffTrendChart({
    super.key,
    required this.points,
    required this.color,
  });

  final List<StaffMetricPoint> points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Center(
        child: Text(
          'No trend available',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    final values = points.map((point) => point.value).toList();
    final minY = values.reduce(math.min);
    final maxY = values.reduce(math.max);
    final span = (maxY - minY).abs();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: points.length - 1,
        minY: math.max(0, minY - math.max(4, span * 0.2)),
        maxY: maxY + math.max(4, span * 0.2),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: span == 0 ? math.max(1, maxY * 0.25) : null,
          getDrawingHorizontalLine: (value) => FlLine(
            color: StaffManagementPalette.border(context),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(enabled: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    points[index].label,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: color,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 3.8,
                    color: Colors.white,
                    strokeColor: color,
                    strokeWidth: 2,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.12),
            ),
            spots: [
              for (var index = 0; index < points.length; index++)
                FlSpot(index.toDouble(), points[index].value),
            ],
          ),
        ],
      ),
    );
  }
}
