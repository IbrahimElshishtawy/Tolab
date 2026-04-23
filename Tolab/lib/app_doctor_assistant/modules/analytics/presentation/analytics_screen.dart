import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../presentation/widgets/workspace/faculty_quick_actions_bar.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';
import 'models/analytics_workspace_models.dart';
import 'widgets/analytics_alerts_section.dart';
import 'widgets/analytics_period_insights_section.dart';
import 'widgets/analytics_students_focus_section.dart';
import 'widgets/grade_distribution_chart.dart';
import 'widgets/subject_insights_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, SessionUser?>(
      converter: (store) => getCurrentUser(store.state),
      builder: (context, user) {
        if (user == null) {
          return const SizedBox.shrink();
        }

        final repository = DoctorAssistantMockRepository.instance;
        final workspace = buildAnalyticsWorkspace(repository, user);

        return DoctorAssistantShell(
          user: user,
          activeRoute: AppRoutes.analytics,
          unreadNotifications: repository.unreadNotificationsFor(user),
          child: DoctorAssistantPageScaffold(
            title: 'Analytics',
            subtitle:
                'Decision-support workspace for student risk, course health, grading momentum, and intervention planning.',
            breadcrumbs: const ['Workspace', 'Analytics'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FacultyQuickActionsBar(user: user),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: workspace.kpis
                      .map(
                        (item) => _KpiCard(item: item),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: AppSpacing.md),
                AnalyticsAlertsSection(alerts: workspace.alerts),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Subject deep insights',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  workspace.summary,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: workspace.subjectInsights
                      .map(
                        (insight) => SizedBox(
                          width: 420,
                          child: SubjectInsightsCard(insight: insight),
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: AppSpacing.md),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 1100;
                    final topStudents = AnalyticsStudentsFocusSection(
                      title: 'Top performers',
                      subtitle:
                          'Students with the strongest combined academic, attendance, and engagement signals.',
                      students: workspace.topPerformers,
                      highlightColor: const Color(0xFF14B8A6),
                    );
                    final attentionStudents = AnalyticsStudentsFocusSection(
                      title: 'Students needing attention',
                      subtitle:
                          'Early intervention queue based on risk label, low activity, and declining academic performance.',
                      students: workspace.studentsNeedingAttention,
                      highlightColor: const Color(0xFFDC2626),
                    );

                    if (!isWide) {
                      return Column(
                        children: [
                          topStudents,
                          const SizedBox(height: AppSpacing.md),
                          attentionStudents,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: topStudents),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: attentionStudents),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                GradeDistributionChart(
                  buckets: workspace.distribution,
                  successCount: workspace.successCount,
                  failureCount: workspace.failureCount,
                ),
                const SizedBox(height: AppSpacing.md),
                AnalyticsPeriodInsightsSection(items: workspace.periodInsights),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.item});

  final AnalyticsKpiItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: item.color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, color: item.color),
          const SizedBox(height: AppSpacing.sm),
          Text(item.label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            item.value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(item.caption, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
