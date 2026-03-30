import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../models/moderation_models.dart';

class ModerationAnalyticsOverview extends StatelessWidget {
  const ModerationAnalyticsOverview({
    super.key,
    required this.analytics,
  });

  final ModerationAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1080;
        final lineChart = _LineChartCard(
          title: 'Moderation activity trend',
          subtitle: 'Reports handled vs flagged content over the week.',
          points: analytics.activityTrend,
        );
        final donutChart = _DonutChartCard(
          title: 'Reports by type',
          subtitle: 'Where moderation pressure is coming from.',
          entries: analytics.reportsByType,
        );
        final groupsChart = _BarChartCard(
          title: 'Reports by group',
          subtitle: 'Communities with the highest moderation load.',
          entries: analytics.reportsByGroup,
        );
        final periodChart = _BarChartCard(
          title: 'Reports by period',
          subtitle: 'Volume distribution across monitoring windows.',
          entries: analytics.reportsByPeriod,
        );

        if (compact) {
          return Column(
            children: [
              SizedBox(height: 360, child: lineChart),
              const SizedBox(height: AppSpacing.md),
              SizedBox(height: 360, child: donutChart),
              const SizedBox(height: AppSpacing.md),
              SizedBox(height: 320, child: groupsChart),
              const SizedBox(height: AppSpacing.md),
              SizedBox(height: 320, child: periodChart),
            ],
          );
        }

        return Column(
          children: [
            SizedBox(
              height: 360,
              child: Row(
                children: [
                  Expanded(child: lineChart),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: donutChart),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 320,
              child: Row(
                children: [
                  Expanded(child: groupsChart),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: periodChart),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LineChartCard extends StatelessWidget {
  const _LineChartCard({
    required this.title,
    required this.subtitle,
    required this.points,
  });

  final String title;
  final String subtitle;
  final List<ModerationTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final maxY = points.fold<double>(
      10,
      (value, point) =>
          value > point.value ? value : point.value + 4,
    );

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Theme.of(context).dividerColor,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      getTitlesWidget: (value, meta) =>
                          Text(value.toInt().toString()),
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
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Text(points[index].label),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    barWidth: 3,
                    color: AppColors.primary,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                    spots: [
                      for (var index = 0; index < points.length; index++)
                        FlSpot(index.toDouble(), points[index].value),
                    ],
                  ),
                  LineChartBarData(
                    isCurved: true,
                    barWidth: 3,
                    color: AppColors.warning,
                    dotData: const FlDotData(show: false),
                    spots: [
                      for (var index = 0; index < points.length; index++)
                        FlSpot(index.toDouble(), points[index].secondaryValue),
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

class _DonutChartCard extends StatelessWidget {
  const _DonutChartCard({
    required this.title,
    required this.subtitle,
    required this.entries,
  });

  final String title;
  final String subtitle;
  final List<ModerationBreakdownEntry> entries;

  @override
  Widget build(BuildContext context) {
    final total = entries.fold<double>(0, (sum, entry) => sum + entry.value);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 44,
                      sectionsSpace: 2,
                      sections: entries
                          .map(
                            (entry) => PieChartSectionData(
                              value: entry.value,
                              color: entry.color,
                              radius: 70,
                              showTitle: false,
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _LegendList(entries: entries, total: total),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartCard extends StatelessWidget {
  const _BarChartCard({
    required this.title,
    required this.subtitle,
    required this.entries,
  });

  final String title;
  final String subtitle;
  final List<ModerationBreakdownEntry> entries;

  @override
  Widget build(BuildContext context) {
    final maxY = entries.fold<double>(
      6,
      (value, entry) => value > entry.value ? value : entry.value + 1,
    );

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxY,
                alignment: BarChartAlignment.spaceAround,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Theme.of(context).dividerColor,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 28),
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
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Text(
                            entries[index].label,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                          toY: entries[index].value,
                          color: entries[index].color,
                          width: 26,
                          borderRadius: BorderRadius.circular(
                            AppConstants.smallRadius,
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

class _LegendList extends StatelessWidget {
  const _LegendList({
    required this.entries,
    required this.total,
  });

  final List<ModerationBreakdownEntry> entries;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                      color: entry.color,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(entry.label)),
                  Text(
                    total == 0
                        ? '0%'
                        : '${((entry.value / total) * 100).round()}%',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
