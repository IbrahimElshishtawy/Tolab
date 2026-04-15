import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../app_admin/core/colors/app_colors.dart';
import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../models/course_workspace_models.dart';
import 'course_workspace_widgets.dart';

class AnalyticsLineChartCard extends StatelessWidget {
  const AnalyticsLineChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.points,
    this.color = AppColors.primary,
  });

  final String title;
  final String subtitle;
  final List<CourseChartPoint> points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return WorkspaceSectionCard(
        title: title,
        subtitle: subtitle,
        child: const SizedBox(height: 220),
      );
    }

    return WorkspaceSectionCard(
      title: title,
      subtitle: subtitle,
      child: SizedBox(
        height: 240,
        child: LineChart(
          LineChartData(
            minY: 0,
            gridData: FlGridData(
              show: true,
              horizontalInterval: _interval(points),
              drawVerticalLine: false,
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  interval: _interval(points),
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
                        style: Theme.of(context).textTheme.bodySmall,
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
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: color.withValues(alpha: .12),
                ),
                spots: List<FlSpot>.generate(
                  points.length,
                  (index) => FlSpot(index.toDouble(), points[index].value),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _interval(List<CourseChartPoint> points) {
    final maxValue = points.fold<double>(0, (max, item) => math.max(max, item.value));
    return maxValue <= 10 ? 2 : (maxValue / 4).ceilToDouble();
  }
}

class AnalyticsBarChartCard extends StatelessWidget {
  const AnalyticsBarChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.points,
  });

  final String title;
  final String subtitle;
  final List<CourseChartPoint> points;

  @override
  Widget build(BuildContext context) {
    return WorkspaceSectionCard(
      title: title,
      subtitle: subtitle,
      child: SizedBox(
        height: 240,
        child: BarChart(
          BarChartData(
            maxY: points.fold<double>(0, (max, item) => math.max(max, item.value)) + 10,
            alignment: BarChartAlignment.spaceAround,
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(drawVerticalLine: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
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
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: List<BarChartGroupData>.generate(points.length, (index) {
              final point = points[index];
              final color = switch (index % 3) {
                0 => AppColors.primary,
                1 => AppColors.info,
                _ => AppColors.warning,
              };
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: point.value,
                    width: 26,
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class AnalyticsDonutChartCard extends StatelessWidget {
  const AnalyticsDonutChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.slices,
  });

  final String title;
  final String subtitle;
  final List<CourseBreakdownSlice> slices;

  @override
  Widget build(BuildContext context) {
    return WorkspaceSectionCard(
      title: title,
      subtitle: subtitle,
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 48,
                  sections: slices
                      .map(
                        (slice) => PieChartSectionData(
                          value: slice.value,
                          color: Color(slice.hexColor),
                          radius: 48,
                          title: '${slice.value.toStringAsFixed(0)}%',
                          titleStyle: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: Colors.white),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: slices
                  .map(
                    (slice) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              color: Color(slice.hexColor),
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              '${slice.label} ${slice.value.toStringAsFixed(0)}%',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
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
