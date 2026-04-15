import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/models/staff_portal_models.dart';
import '../providers/staff_portal_providers.dart';
import '../widgets/analytics_chart_card.dart';
import '../widgets/course_health_card.dart';
import 'add_announcement_page.dart';
import 'add_lecture_page.dart';
import 'add_quiz_page.dart';

class DoctorHomePage extends ConsumerWidget {
  const DoctorHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(staffDashboardProvider);

    return SafeArea(
      child: AdaptivePageContainer(
        child: dashboardAsync.when(
          data: (dashboard) => ListView(
            children: [
              _HeaderCard(profile: dashboard.profile),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: dashboard.quickActions
                    .map((action) => _QuickActionTile(action: action))
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionTitle(
                title: context.tr('Action Required', 'Action Required'),
                subtitle: context.tr(
                  'العناصر التي تحتاج قرارًا أو متابعة سريعة',
                  'The items that need the next decision or quick follow-up',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...dashboard.actionRequired.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _ActionRequiredCard(item: item),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionTitle(
                title: context.tr('Today Focus', 'Today Focus'),
                subtitle: context.tr(
                  'محاضرات اليوم وأقرب المواعيد والكويزات المفتوحة',
                  'Today sessions, closest deadlines, and live quizzes',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...dashboard.todayFocus.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: AppCard(
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: context.theme.colorScheme.primary.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(item.meta),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(item.subtitle),
                            ],
                          ),
                        ),
                        Text(item.typeLabel),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              LayoutBuilder(
                builder: (context, constraints) {
                  final stacked = constraints.maxWidth < 980;
                  final left = Column(
                    children: [
                      CourseHealthCard(summary: dashboard.courseHealth),
                      const SizedBox(height: AppSpacing.lg),
                      AnalyticsChartCard(
                        title: context.tr(
                          'Activity this week',
                          'Activity this week',
                        ),
                        subtitle: context.tr(
                          'قراءة سريعة لتفاعل الطلبة',
                          'A quick trend for student activity',
                        ),
                        child: MiniLineChart(
                          points: dashboard.analytics.activityTrend,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  );
                  final right = Column(
                    children: [
                      AnalyticsChartCard(
                        title: context.tr(
                          'Submission pulse',
                          'Submission pulse',
                        ),
                        subtitle: context.tr(
                          'متابعة موجة التسليمات',
                          'Momentum of submissions across recent milestones',
                        ),
                        child: MiniBarChart(
                          points: dashboard.analytics.submissionTrend,
                          color: AppColors.teal,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AnalyticsChartCard(
                        title: context.tr(
                          'Performance split',
                          'Performance split',
                        ),
                        subtitle: context.tr(
                          'High / medium / low performers',
                          'High / medium / low performers',
                        ),
                        child: MiniDonutChart(
                          items: dashboard.analytics.performanceBands,
                          centerLabel: context.tr('الأداء', 'Performance'),
                        ),
                      ),
                    ],
                  );

                  if (stacked) {
                    return Column(
                      children: [
                        left,
                        const SizedBox(height: AppSpacing.lg),
                        right,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: left),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: right),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionTitle(
                title: context.tr('Student Insights', 'Student Insights'),
                subtitle: context.tr(
                  'الطلبة الذين يحتاجون متابعة أو تدخل',
                  'Students who currently need attention or intervention',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...dashboard.studentInsights.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text(item.subjectName),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(item.reason),
                        const SizedBox(height: AppSpacing.xs),
                        Text(item.engagementLabel),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionTitle(
                title: context.tr('Activity Feed', 'Activity Feed'),
                subtitle: context.tr(
                  'آخر ما حدث عبر المقررات',
                  'Latest announcements, posts, and assessment changes',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...dashboard.activityFeed.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text(item.typeLabel),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(item.subjectName),
                        const SizedBox(height: AppSpacing.sm),
                        Text(item.description),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          loading: () =>
              const LoadingWidget(label: 'Loading academic workspace...'),
          error: (error, _) => ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.profile});

  final StaffProfile profile;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: context.theme.colorScheme.surfaceContainerHighest
          .withValues(alpha: 0.65),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(
              'مساحة عمل أكاديمية للدكتور والمعيد',
              'Academic workspace for doctors and assistants',
            ),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${profile.fullName} • ${profile.roleLabel} • ${profile.department}',
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              _Pill(label: profile.title),
              _Pill(label: profile.office),
              _Pill(label: profile.email),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends ConsumerWidget {
  const _QuickActionTile({required this.action});

  final StaffQuickAction action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 240,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_iconFor(action.iconName), color: AppColors.primary),
            const SizedBox(height: AppSpacing.md),
            Text(
              action.title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(action.subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: context.tr('فتح', 'Open'),
              isExpanded: false,
              onPressed: action.subjectId == null
                  ? null
                  : () => _openAction(context, action),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAction(
    BuildContext context,
    StaffQuickAction action,
  ) async {
    final subjectId = action.subjectId!;
    switch (action.id) {
      case 'add_quiz':
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AddQuizPage(subjectId: subjectId)),
        );
      case 'add_announcement':
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddAnnouncementPage(subjectId: subjectId),
          ),
        );
      case 'add_lecture':
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddLecturePage(subjectId: subjectId),
          ),
        );
      case 'view_students':
        context.goNamed(
          RouteNames.subjectDetails,
          pathParameters: {'subjectId': subjectId},
        );
    }
  }

  IconData _iconFor(String iconName) {
    return switch (iconName) {
      'quiz' => Icons.quiz_outlined,
      'campaign' => Icons.campaign_outlined,
      'smart_display' => Icons.smart_display_rounded,
      'groups' => Icons.groups_rounded,
      _ => Icons.bolt_rounded,
    };
  }
}

class _ActionRequiredCard extends StatelessWidget {
  const _ActionRequiredCard({required this.item});

  final StaffActionRequiredItem item;

  @override
  Widget build(BuildContext context) {
    final color = switch (item.priority) {
      StaffPriority.high => AppColors.error,
      StaffPriority.medium => AppColors.warning,
      StaffPriority.low => AppColors.success,
    };

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(item.subjectName),
                const SizedBox(height: AppSpacing.sm),
                Text(item.description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}

extension on BuildContext {
  ThemeData get theme => Theme.of(this);
}
