import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/home_dashboard.dart';
import '../../../../core/models/notification_item.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/responsive_wrap_grid.dart';
import '../providers/home_providers.dart';

class StudentHomePage extends ConsumerWidget {
  const StudentHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelAsync = ref.watch(studentHomeViewModelProvider);

    return SafeArea(
      child: AdaptivePageContainer(
        child: viewModelAsync.when(
          data: (viewModel) => ListView(
            children: [
              _HomeHero(viewModel: viewModel),
              const SizedBox(height: AppSpacing.lg),
              const _SectionTitle(
                title: 'المطلوب منك الآن',
                subtitle:
                    'أولوية اليوم مرتبة تلقائيًا حسب الاستعجال حتى تعرف ما يستحق التدخل أولًا.',
              ),
              const SizedBox(height: AppSpacing.md),
              ResponsiveWrapGrid(
                minItemWidth: 230,
                spacing: AppSpacing.sm,
                children: [
                  for (final item in viewModel.requiredTodayItems)
                    _RequiredActionCard(item: item),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const _SectionTitle(
                title: 'جدولك الدراسي',
                subtitle:
                    'عرض ذكي لما سيحدث اليوم ثم غدًا خلال المواد الحالية.',
              ),
              const SizedBox(height: AppSpacing.md),
              _AgendaSection(groups: viewModel.timelineGroups),
              const SizedBox(height: AppSpacing.lg),
              ResponsiveWrapGrid(
                minItemWidth: 280,
                spacing: AppSpacing.md,
                children: [
                  _SnapshotSection(viewModel: viewModel),
                  _TipSection(viewModel: viewModel),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const _SectionTitle(
                title: 'آخر النشاط',
                subtitle:
                    'محاضرات جديدة وكويزات وإعلانات ودرجات مضافة داخل المواد.',
              ),
              const SizedBox(height: AppSpacing.md),
              _RecentActivitySection(
                activities: viewModel.courseActivities,
                notifications: viewModel.notificationsPreview,
              ),
            ],
          ),
          loading: () =>
              const LoadingWidget(label: 'جارٍ تحميل لوحة الطالب...'),
          error: (error, _) => ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.viewModel});

  final StudentHomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return AppCard(
      backgroundColor: palette.surfaceElevated,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.profile.fullName,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Student Academic Workspace',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              AppBadge(
                label: viewModel.profile.academicStatus,
                backgroundColor: AppColors.success.withValues(alpha: 0.12),
                foregroundColor: AppColors.success,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _HeroInfoTile(
                label: 'Department',
                value: viewModel.profile.department,
              ),
              _HeroInfoTile(label: 'Level', value: viewModel.profile.level),
              _HeroInfoTile(
                label: 'Student ID',
                value: viewModel.profile.studentNumber,
              ),
              _HeroInfoTile(
                label: 'GPA',
                value: viewModel.profile.gpa.toStringAsFixed(2),
                accent: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RequiredActionCard extends StatelessWidget {
  const _RequiredActionCard({required this.item});

  final StudentRequiredActionItem item;

  @override
  Widget build(BuildContext context) {
    final accent = _priorityColor(item.priority);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(item.icon, size: 20, color: accent),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppBadge(
                  label: _priorityLabel(item.priority),
                  backgroundColor: accent.withValues(alpha: 0.12),
                  foregroundColor: accent,
                  dense: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.title,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(item.subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.meta,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: item.ctaLabel,
            onPressed: item.target == null
                ? null
                : () => _openTarget(context, item.target!),
            isExpanded: false,
            icon: Icons.arrow_forward_rounded,
          ),
        ],
      ),
    );
  }
}

class _AgendaSection extends StatelessWidget {
  const _AgendaSection({required this.groups});

  final List<StudentTimelineGroup> groups;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const AppCard(child: Text('لا توجد عناصر قريبة في الجدول الآن.'));
    }

    return Column(
      children: [
        for (final group in groups) ...[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                for (final item in group.items) ...[
                  _TimelineTile(item: item),
                  if (item != group.items.last)
                    const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          ),
          if (group != groups.last) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.item});

  final StudentTimelineItem item;

  @override
  Widget build(BuildContext context) {
    final accent = _priorityColor(item.priority);

    return InkWell(
      onTap: item.target == null
          ? null
          : () => _openTarget(context, item.target!),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 52,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${item.subtitle} • ${item.timeLabel}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            AppBadge(
              label: _timelineKindLabel(item.kind),
              backgroundColor: accent.withValues(alpha: 0.12),
              foregroundColor: accent,
              dense: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SnapshotSection extends StatelessWidget {
  const _SnapshotSection({required this.viewModel});

  final StudentHomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص أكاديمي سريع',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          ResponsiveWrapGrid(
            minItemWidth: 132,
            spacing: AppSpacing.sm,
            children: [
              _MetricTile(
                label: 'GPA',
                value: viewModel.academicSnapshot.gpa.toStringAsFixed(2),
              ),
              _MetricTile(
                label: 'المواد',
                value: '${viewModel.academicSnapshot.courseCount}',
              ),
              _MetricTile(
                label: 'كويزات الأسبوع',
                value: '${viewModel.upcomingQuizzes.length}',
              ),
              _MetricTile(
                label: 'تكليفات مفتوحة',
                value: '${viewModel.academicSnapshot.pendingTasks}',
              ),
              _MetricTile(
                label: 'عناصر مكتملة',
                value: '${viewModel.academicSnapshot.completedTasks}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TipSection extends StatelessWidget {
  const _TipSection({required this.viewModel});

  final StudentHomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نصيحة أكاديمية اليوم',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            viewModel.dailyTip,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.md),
          ...viewModel.studyInsights.tips
              .take(3)
              .map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          size: 16,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          tip,
                          style: Theme.of(context).textTheme.bodySmall,
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

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection({
    required this.activities,
    required this.notifications,
  });

  final List<CourseActivityItem> activities;
  final List<AppNotificationItem> notifications;

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapGrid(
      minItemWidth: 320,
      spacing: AppSpacing.md,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'داخل المواد',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              ...activities
                  .take(4)
                  .map(
                    (activity) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _ActivityTile(
                        title: activity.title,
                        subtitle: activity.subjectName,
                        description: activity.description,
                        meta: activity.createdAtLabel,
                        accent: _activityColor(activity.type),
                      ),
                    ),
                  ),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'التنبيهات الأحدث',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              ...notifications.map(
                (notification) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _ActivityTile(
                    title: notification.title,
                    subtitle: notification.subjectName ?? notification.category,
                    description: notification.body,
                    meta: notification.createdAtLabel,
                    accent: _notificationColor(notification.urgency),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.meta,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final String description;
  final String meta;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 56,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  meta,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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

class _HeroInfoTile extends StatelessWidget {
  const _HeroInfoTile({required this.label, required this.value, this.accent});

  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return Container(
      width: 172,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

String _priorityLabel(StudentPriority priority) {
  return switch (priority) {
    StudentPriority.urgent => 'عاجل',
    StudentPriority.soon => 'قريب',
    StudentPriority.safe => 'مستقر',
  };
}

Color _priorityColor(StudentPriority priority) {
  return switch (priority) {
    StudentPriority.urgent => AppColors.error,
    StudentPriority.soon => AppColors.warning,
    StudentPriority.safe => AppColors.success,
  };
}

String _timelineKindLabel(StudentTimelineKind kind) {
  return switch (kind) {
    StudentTimelineKind.lecture => 'محاضرة',
    StudentTimelineKind.section => 'سكشن',
    StudentTimelineKind.quiz => 'كويز',
    StudentTimelineKind.task => 'تكليف',
  };
}

Color _activityColor(CourseActivityType type) {
  return switch (type) {
    CourseActivityType.lecture => AppColors.primary,
    CourseActivityType.quiz => AppColors.error,
    CourseActivityType.assignment => AppColors.warning,
    CourseActivityType.groupPost => AppColors.indigo,
    CourseActivityType.announcement => AppColors.success,
  };
}

Color _notificationColor(NotificationUrgency urgency) {
  return switch (urgency) {
    NotificationUrgency.newItem => AppColors.primary,
    NotificationUrgency.important => AppColors.warning,
    NotificationUrgency.urgent => AppColors.error,
  };
}

void _openTarget(BuildContext context, StudentActionTarget target) {
  context.goNamed(target.routeName, pathParameters: target.pathParameters);
}
