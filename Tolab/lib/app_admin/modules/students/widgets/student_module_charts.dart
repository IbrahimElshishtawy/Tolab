import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../models/student_management_models.dart';

class StudentLineTrendChart extends StatelessWidget {
  const StudentLineTrendChart({
    super.key,
    required this.points,
  });

  final List<StudentEnrollmentPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();
    return LineChart(
      LineChartData(
        minY: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 40,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 34),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
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
                  child: Text(points[index].label),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var index = 0; index < points.length; index++)
                FlSpot(index.toDouble(), points[index].value),
            ],
            isCurved: true,
            barWidth: 3,
            color: AppColors.primary,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.18),
                  AppColors.primary.withValues(alpha: 0.02),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.primary,
                strokeColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StudentDepartmentBarChart extends StatelessWidget {
  const StudentDepartmentBarChart({
    super.key,
    required this.distribution,
  });

  final Map<String, int> distribution;

  @override
  Widget build(BuildContext context) {
    final entries = distribution.entries.toList();
    if (entries.isEmpty) return const SizedBox.shrink();
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: entries
                .map((entry) => entry.value)
                .fold<int>(0, (maxValue, value) => value > maxValue ? value : maxValue)
                .toDouble() +
            1,
        barTouchData: BarTouchData(enabled: true),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 32),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= entries.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(entries[index].key.split(' ').first),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var index = 0; index < entries.length; index++)
            BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: entries[index].value.toDouble(),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  width: 22,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.info],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class StudentDonutChart extends StatelessWidget {
  const StudentDonutChart({
    super.key,
    required this.pending,
    required this.active,
    required this.watchlist,
  });

  final int pending;
  final int active;
  final int watchlist;

  @override
  Widget build(BuildContext context) {
    final total = pending + active + watchlist;
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sectionsSpace: 4,
            centerSpaceRadius: 42,
            sections: [
              PieChartSectionData(
                color: AppColors.warning,
                value: pending.toDouble(),
                title: '',
                radius: 44,
              ),
              PieChartSectionData(
                color: AppColors.success,
                value: active.toDouble(),
                title: '',
                radius: 44,
              ),
              PieChartSectionData(
                color: AppColors.danger,
                value: watchlist.toDouble(),
                title: '',
                radius: 44,
              ),
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$total', style: Theme.of(context).textTheme.headlineSmall),
            Text(
              'students',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
