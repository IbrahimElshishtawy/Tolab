import 'package:flutter/material.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/models/staff_portal_models.dart';
import '../widgets/analytics_chart_card.dart';

class CourseAnalyticsPage extends StatelessWidget {
  const CourseAnalyticsPage({super.key, required this.analytics});

  final StaffAnalyticsData analytics;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _AnalyticsMetricCard(
              label: context.tr('إجمالي الطلبة', 'Total students'),
              value: '${analytics.totalStudents}',
            ),
            _AnalyticsMetricCard(
              label: context.tr('الطلبة النشطون', 'Active students'),
              value: '${analytics.activeStudents}',
            ),
            _AnalyticsMetricCard(
              label: context.tr('إكمال الكويز', 'Quiz completion'),
              value: '${analytics.quizCompletionRate.round()}%',
            ),
            _AnalyticsMetricCard(
              label: context.tr('متوسط الدرجات', 'Average score'),
              value: '${analytics.averageScore.round()}%',
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AnalyticsChartCard(
          title: context.tr('النشاط عبر الوقت', 'Activity over time'),
          subtitle: context.tr(
            'اتجاه تفاعل الطلبة هذا الأسبوع',
            'Student engagement trend across the week',
          ),
          child: MiniLineChart(
            points: analytics.activityTrend,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AnalyticsChartCard(
          title: context.tr('اتجاه التسليمات', 'Submission trend'),
          subtitle: context.tr(
            'قراءة سريعة لوتيرة التسليمات',
            'A fast look at delivery pace by milestone',
          ),
          child: MiniBarChart(
            points: analytics.submissionTrend,
            color: AppColors.teal,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 860;
            final charts = [
              Expanded(
                child: AnalyticsChartCard(
                  title: context.tr('توزيع الأداء', 'Performance distribution'),
                  subtitle: context.tr(
                    'High vs medium vs low performers',
                    'High vs medium vs low performers',
                  ),
                  child: MiniDonutChart(
                    items: analytics.performanceBands,
                    centerLabel: context.tr('الأداء', 'Performance'),
                  ),
                ),
              ),
              Expanded(
                child: AnalyticsChartCard(
                  title: context.tr(
                    'مكتمل مقابل معلّق',
                    'Completed vs pending',
                  ),
                  subtitle: context.tr(
                    'قراءة مباشرة لمستوى الإنجاز',
                    'Instant read for completion status',
                  ),
                  child: MiniDonutChart(
                    items: analytics.completionSplit,
                    centerLabel: context.tr('التسليمات', 'Completion'),
                  ),
                ),
              ),
            ];

            if (stacked) {
              return Column(
                children: [
                  charts[0],
                  const SizedBox(height: AppSpacing.lg),
                  charts[1],
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                charts[0],
                const SizedBox(width: AppSpacing.lg),
                charts[1],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AnalyticsMetricCard extends StatelessWidget {
  const _AnalyticsMetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
