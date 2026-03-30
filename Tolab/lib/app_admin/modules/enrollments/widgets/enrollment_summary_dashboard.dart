import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/models/dashboard_models.dart';
import '../../../shared/widgets/metric_card.dart';
import '../models/enrollment_models.dart';
import 'enrollment_chart_widget.dart';
import 'enrollment_progress_widget.dart';

class EnrollmentSummaryDashboard extends StatelessWidget {
  const EnrollmentSummaryDashboard({super.key, required this.summary});

  final EnrollmentDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            SizedBox(
              width: isMobile ? double.infinity : 280,
              child: MetricCard(
                metric: KpiMetric(
                  label: 'Total enrollments',
                  value: summary.totalEnrollments.toString(),
                  delta: '${summary.enrolledCount} approved',
                  color: AppColors.primary,
                  icon: Icons.groups_rounded,
                ),
              ),
            ),
            SizedBox(
              width: isMobile ? double.infinity : 280,
              child: MetricCard(
                metric: KpiMetric(
                  label: 'Pending review',
                  value: summary.pendingCount.toString(),
                  delta: '${summary.rejectedCount} rejected',
                  color: AppColors.warning,
                  icon: Icons.pending_actions_rounded,
                ),
              ),
            ),
            SizedBox(
              width: isMobile ? double.infinity : 280,
              child: MetricCard(
                metric: KpiMetric(
                  label: 'Section occupancy',
                  value: '${(summary.averageOccupancy * 100).round()}%',
                  delta: 'Average utilization',
                  color: AppColors.secondary,
                  icon: Icons.stacked_bar_chart_rounded,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 1100) {
              return Column(
                children: [
                  EnrollmentChartWidget(
                    title: 'Status distribution',
                    subtitle: 'Live approval mix across the active roster.',
                    mode: EnrollmentChartMode.pie,
                    summary: summary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  EnrollmentChartWidget(
                    title: 'Course load',
                    subtitle:
                        'Enrollment status counts across the busiest courses.',
                    mode: EnrollmentChartMode.bar,
                    summary: summary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _OccupancyCard(summary: summary),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: EnrollmentChartWidget(
                    title: 'Status distribution',
                    subtitle: 'Live approval mix across the active roster.',
                    mode: EnrollmentChartMode.pie,
                    summary: summary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: EnrollmentChartWidget(
                    title: 'Course load',
                    subtitle:
                        'Enrollment status counts across the busiest courses.',
                    mode: EnrollmentChartMode.bar,
                    summary: summary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SizedBox(width: 360, child: _OccupancyCard(summary: summary)),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _OccupancyCard extends StatelessWidget {
  const _OccupancyCard({required this.summary});

  final EnrollmentDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Section occupancy',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Capacity signal for the busiest sections in the current roster.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (summary.sectionSummary.isEmpty)
            Text(
              'Occupancy insights will appear after the first enrollment sync.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            ...summary.sectionSummary.take(5).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: EnrollmentProgressWidget(
                  value: item.progress,
                  label: '${item.sectionName} • ${item.courseLabel}',
                  trailing: '${item.occupied}/${item.capacity}',
                ),
              );
            }),
        ],
      ),
    );
  }
}
