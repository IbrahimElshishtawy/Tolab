import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../models/dashboard_models.dart';

class EnrollmentTrendCard extends StatelessWidget {
  const EnrollmentTrendCard({super.key, required this.points});

  final List<DashboardLinePoint> points;

  @override
  Widget build(BuildContext context) {
    final maxY = points.isEmpty
        ? 100
        : points.map((point) => point.value).reduce((a, b) => a > b ? a : b);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enrollment trend',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Application and confirmation movement across the active semester.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 300,
            child: LineChart(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              LineChartData(
                minX: 0,
                maxX: (points.length - 1).toDouble(),
                minY: 0,
                maxY: maxY * 1.18,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.slateSoft.withValues(alpha: 0.45),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.textPrimaryLight,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index < 0 || index >= points.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            points[index].label,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    barWidth: 4,
                    color: AppColors.primary,
                    spots: [
                      for (var index = 0; index < points.length; index++)
                        FlSpot(index.toDouble(), points[index].value),
                    ],
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                        radius: 3.8,
                        color: AppColors.primary,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.26),
                          AppColors.primary.withValues(alpha: 0.02),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StudentDistributionCard extends StatelessWidget {
  const StudentDistributionCard({super.key, required this.slices});

  final List<DashboardPieSlice> slices;

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<double>(0, (sum, item) => sum + item.value);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student distribution',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Visible cohort split by academic year for the selected scope.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 250,
            child: PieChart(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              PieChartData(
                centerSpaceRadius: 62,
                sectionsSpace: 3,
                sections: [
                  for (final slice in slices)
                    PieChartSectionData(
                      value: slice.value,
                      color: _toneColor(slice.tone),
                      radius: 24,
                      showTitle: false,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final slice in slices)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                      color: _toneColor(slice.tone),
                      borderRadius: BorderRadius.circular(
                        AppConstants.pillRadius,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(slice.label)),
                  Text(
                    '${total == 0 ? 0 : ((slice.value / total) * 100).round()}%',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class AttendanceOverviewCard extends StatelessWidget {
  const AttendanceOverviewCard({super.key, required this.points});

  final List<DashboardBarPoint> points;

  @override
  Widget build(BuildContext context) {
    return _DashboardBarCard(
      title: 'Attendance overview',
      subtitle:
          'Average attendance through the week, calibrated against the 90% baseline.',
      points: points,
      color: AppColors.info,
      valueSuffix: '%',
    );
  }
}

class StaffPerformanceCard extends StatelessWidget {
  const StaffPerformanceCard({super.key, required this.points});

  final List<DashboardBarPoint> points;

  @override
  Widget build(BuildContext context) {
    return _DashboardBarCard(
      title: 'Staff performance',
      subtitle:
          'Delivery quality, responsiveness, and continuity by instructor.',
      points: points,
      color: AppColors.secondary,
      valueSuffix: '',
    );
  }
}

class _DashboardBarCard extends StatelessWidget {
  const _DashboardBarCard({
    required this.title,
    required this.subtitle,
    required this.points,
    required this.color,
    required this.valueSuffix,
  });

  final String title;
  final String subtitle;
  final List<DashboardBarPoint> points;
  final Color color;
  final String valueSuffix;

  @override
  Widget build(BuildContext context) {
    final maxY = points.isEmpty
        ? 100
        : points
              .map((point) => point.target ?? point.value)
              .reduce((a, b) => a > b ? a : b);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 260,
            child: BarChart(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              BarChartData(
                maxY: maxY * 1.2,
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.slateSoft.withValues(alpha: 0.45),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.textPrimaryLight,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, _) => Text(
                        '${value.toInt()}$valueSuffix',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
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
                barGroups: [
                  for (var index = 0; index < points.length; index++)
                    BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: points[index].value,
                          width: 18,
                          borderRadius: BorderRadius.circular(10),
                          color: color,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: points[index].target ?? maxY,
                            color: color.withValues(alpha: 0.10),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _toneColor(DashboardMetricTone tone) {
  return switch (tone) {
    DashboardMetricTone.secondary => AppColors.secondary,
    DashboardMetricTone.info => AppColors.info,
    DashboardMetricTone.success => AppColors.secondary,
    DashboardMetricTone.warning => AppColors.warning,
    DashboardMetricTone.danger => AppColors.danger,
    DashboardMetricTone.primary => AppColors.primary,
  };
}
