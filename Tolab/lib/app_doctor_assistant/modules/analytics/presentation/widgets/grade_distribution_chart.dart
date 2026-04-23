import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../models/analytics_workspace_models.dart';

class GradeDistributionChart extends StatelessWidget {
  const GradeDistributionChart({
    super.key,
    required this.buckets,
    required this.successCount,
    required this.failureCount,
  });

  final List<AnalyticsDistributionBucket> buckets;
  final int successCount;
  final int failureCount;

  @override
  Widget build(BuildContext context) {
    final maxValue = buckets.isEmpty
        ? 1.0
        : buckets.fold<int>(0, (sum, bucket) => sum > bucket.count ? sum : bucket.count).toDouble();

    return DoctorAssistantPanel(
      title: 'Grade distribution',
      subtitle:
          'Histogram view for score spread plus a fast success/failure split to guide grading and remediation decisions.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                maxY: maxValue + 1,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  horizontalInterval: 1,
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      interval: 1,
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
                        if (index < 0 || index >= buckets.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Text(
                            buckets[index].label,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: buckets
                    .asMap()
                    .entries
                    .map(
                      (entry) => BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.count.toDouble(),
                            width: 22,
                            borderRadius: BorderRadius.circular(8),
                            color: entry.value.color,
                          ),
                        ],
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _SplitCard(
                label: 'Success',
                value: '$successCount students',
                color: const Color(0xFF14B8A6),
              ),
              _SplitCard(
                label: 'Failure',
                value: '$failureCount students',
                color: const Color(0xFFDC2626),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SplitCard extends StatelessWidget {
  const _SplitCard({
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
