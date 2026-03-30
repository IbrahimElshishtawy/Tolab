import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../models/enrollment_models.dart';

enum EnrollmentChartMode { pie, bar }

class EnrollmentChartWidget extends StatelessWidget {
  const EnrollmentChartWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.mode,
    required this.summary,
  });

  final String title;
  final String subtitle;
  final EnrollmentChartMode mode;
  final EnrollmentDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 220,
            child: mode == EnrollmentChartMode.pie
                ? _PieChart(summary: summary)
                : _BarChart(summary: summary),
          ),
        ],
      ),
    );
  }
}

class _PieChart extends StatelessWidget {
  const _PieChart({required this.summary});

  final EnrollmentDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final total = summary.totalEnrollments == 0 ? 1 : summary.totalEnrollments;
    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 48,
              sections: summary.statusBreakdown
                  .map((slice) {
                    return PieChartSectionData(
                      color: slice.status.color,
                      value: slice.count.toDouble(),
                      title: '${((slice.count / total) * 100).round()}%',
                      radius: 58,
                      titleStyle: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    );
                  })
                  .toList(growable: false),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 140,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: summary.statusBreakdown
                .map((slice) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: slice.status.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            slice.status.label,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Text(
                          slice.count.toString(),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  );
                })
                .toList(growable: false),
          ),
        ),
      ],
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.summary});

  final EnrollmentDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final courses = summary.courseSummary.take(5).toList(growable: false);
    final maxValue = courses.isEmpty
        ? 1.0
        : courses
              .map((item) => item.total)
              .reduce((a, b) => a > b ? a : b)
              .toDouble();

    return BarChart(
      BarChartData(
        maxY: maxValue + 2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.slateSoft.withValues(alpha: 0.48),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= courses.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    courses[index].courseLabel.split('•').first.trim(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List<BarChartGroupData>.generate(courses.length, (index) {
          final course = courses[index];
          return BarChartGroupData(
            x: index,
            barsSpace: 6,
            barRods: [
              BarChartRodData(
                toY: course.enrolledCount.toDouble(),
                width: 14,
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(16),
              ),
              BarChartRodData(
                toY: course.pendingCount.toDouble(),
                width: 14,
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(16),
              ),
              BarChartRodData(
                toY: course.rejectedCount.toDouble(),
                width: 14,
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(16),
              ),
            ],
          );
        }),
      ),
    );
  }
}
