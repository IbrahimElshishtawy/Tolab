import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../state/dashboard_state.dart';

class StudentsCoursesTrendCard extends StatefulWidget {
  const StudentsCoursesTrendCard({super.key, required this.points});

  final List<DashboardTrendPoint> points;

  @override
  State<StudentsCoursesTrendCard> createState() =>
      _StudentsCoursesTrendCardState();
}

class _StudentsCoursesTrendCardState extends State<StudentsCoursesTrendCard> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final chartWidth = math.max(widget.points.length * 110.0, 680.0);
    final maxStudents = widget.points
        .map((point) => point.totalStudents)
        .fold<double>(0, math.max);
    final maxCourses = widget.points
        .map((point) => point.activeCourses)
        .fold<double>(0, math.max);
    final maxY = math.max(maxStudents, maxCourses * 100) * 1.14;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            title: 'Students / active courses trend',
            subtitle:
                'Tap the chart for precise values as enrollment and teaching load move together.',
          ),
          const SizedBox(height: AppSpacing.md),
          const _LegendRow(
            items: [
              _LegendItem(label: 'Students', color: AppColors.primary),
              _LegendItem(label: 'Active courses x100', color: AppColors.info),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 320,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: chartWidth,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: maxY,
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      horizontalInterval: maxY / 4,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: Theme.of(context).dividerColor,
                        strokeWidth: 1,
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
                          interval: maxY / 4,
                          reservedSize: 52,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              value >= 1000
                                  ? '${(value / 1000).toStringAsFixed(1)}k'
                                  : value.toStringAsFixed(0),
                              style: Theme.of(context).textTheme.bodySmall,
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= widget.points.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.sm,
                              ),
                              child: Text(
                                widget.points[index].label,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchCallback: (event, response) {
                        if (!event.isInterestedForInteractions ||
                            response?.lineBarSpots == null ||
                            response!.lineBarSpots!.isEmpty) {
                          if (_touchedIndex != null) {
                            setState(() => _touchedIndex = null);
                          }
                          return;
                        }
                        setState(
                          () => _touchedIndex = response.lineBarSpots!.first.x
                              .toInt(),
                        );
                      },
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => Theme.of(context).cardColor,
                        getTooltipItems: (spots) {
                          return spots
                              .map((spot) {
                                final point = widget.points[spot.x.toInt()];
                                final label = spot.barIndex == 0
                                    ? 'Students ${point.totalStudents.toStringAsFixed(0)}'
                                    : 'Courses ${point.activeCourses.toStringAsFixed(0)}';
                                return LineTooltipItem(
                                  '$label\n${point.label}',
                                  Theme.of(context).textTheme.bodySmall!,
                                );
                              })
                              .toList(growable: false);
                        },
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 4,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) =>
                              FlDotCirclePainter(
                                radius: _touchedIndex == index ? 5 : 3,
                                color: AppColors.primary,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.28),
                              AppColors.primary.withValues(alpha: 0.04),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        spots: [
                          for (var i = 0; i < widget.points.length; i++)
                            FlSpot(
                              i.toDouble(),
                              widget.points[i].totalStudents,
                            ),
                        ],
                      ),
                      LineChartBarData(
                        isCurved: true,
                        color: AppColors.info,
                        barWidth: 3,
                        dashArray: const [10, 6],
                        dotData: const FlDotData(show: false),
                        spots: [
                          for (var i = 0; i < widget.points.length; i++)
                            FlSpot(
                              i.toDouble(),
                              widget.points[i].activeCourses * 100,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EnrollmentDepartmentBarCard extends StatefulWidget {
  const EnrollmentDepartmentBarCard({super.key, required this.points});

  final List<DashboardDepartmentStat> points;

  @override
  State<EnrollmentDepartmentBarCard> createState() =>
      _EnrollmentDepartmentBarCardState();
}

class _EnrollmentDepartmentBarCardState
    extends State<EnrollmentDepartmentBarCard> {
  int? _touchedGroup;

  @override
  Widget build(BuildContext context) {
    final chartWidth = math.max(widget.points.length * 120.0, 720.0);
    final maxY =
        widget.points
            .map((point) => point.enrollments)
            .fold<double>(0, math.max) *
        1.2;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            title: 'Enrollment per department',
            subtitle:
                'Hover or tap bars to compare academic demand across departments.',
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 320,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: chartWidth,
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      horizontalInterval: maxY / 4,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: Theme.of(context).dividerColor,
                        strokeWidth: 1,
                      ),
                    ),
                    alignment: BarChartAlignment.spaceAround,
                    borderData: FlBorderData(show: false),
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
                          interval: maxY / 4,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const SizedBox.shrink();
                            return Text(
                              '${(value / 1000).toStringAsFixed(1)}k',
                              style: Theme.of(context).textTheme.bodySmall,
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= widget.points.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(
                                top: AppSpacing.sm,
                              ),
                              child: Text(
                                widget.points[index].department,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchCallback: (event, response) {
                        setState(
                          () => _touchedGroup =
                              response?.spot?.touchedBarGroupIndex,
                        );
                      },
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => Theme.of(context).cardColor,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final point = widget.points[group.x.toInt()];
                          return BarTooltipItem(
                            '${point.department}\n${point.enrollments.toStringAsFixed(0)} enrollments',
                            Theme.of(context).textTheme.bodySmall!,
                          );
                        },
                      ),
                    ),
                    barGroups: [
                      for (var i = 0; i < widget.points.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: widget.points[i].enrollments,
                              width: _touchedGroup == i ? 32 : 26,
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [
                                  _toneColor(
                                    widget.points[i].tone,
                                  ).withValues(alpha: 0.55),
                                  _toneColor(widget.points[i].tone),
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PendingApprovalsDonutCard extends StatefulWidget {
  const PendingApprovalsDonutCard({super.key, required this.slices});

  final List<DashboardTaskSlice> slices;

  @override
  State<PendingApprovalsDonutCard> createState() =>
      _PendingApprovalsDonutCardState();
}

class _PendingApprovalsDonutCardState extends State<PendingApprovalsDonutCard> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.slices.fold<double>(
      0,
      (sum, slice) => sum + slice.value,
    );

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            title: 'Pending approvals / tasks',
            subtitle:
                'Real-time workload split between approvals, content validation, and review operations.',
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 48,
                      sectionsSpace: 4,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            _touchedIndex =
                                response?.touchedSection?.touchedSectionIndex ??
                                -1;
                          });
                        },
                      ),
                      sections: [
                        for (var i = 0; i < widget.slices.length; i++)
                          PieChartSectionData(
                            color: _toneColor(widget.slices[i].tone),
                            value: widget.slices[i].value,
                            title: widget.slices[i].value.toStringAsFixed(0),
                            radius: _touchedIndex == i ? 76 : 66,
                            titleStyle: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: Colors.white),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${total.toStringAsFixed(0)} open tasks',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Every segment feeds the notification badge and FIFO toast pipeline in the top shell.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    for (final slice in widget.slices) ...[
                      _LegendTile(
                        label: slice.label,
                        value: slice.value.toStringAsFixed(0),
                        color: _toneColor(slice.tone),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.items});

  final List<_LegendItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: items,
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _LegendTile extends StatelessWidget {
  const _LegendTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

Color _toneColor(DashboardMetricTone tone) => switch (tone) {
  DashboardMetricTone.primary => AppColors.primary,
  DashboardMetricTone.info => AppColors.info,
  DashboardMetricTone.success => AppColors.secondary,
  DashboardMetricTone.warning => AppColors.warning,
  DashboardMetricTone.danger => AppColors.danger,
};
