import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/home_dashboard.dart';
import '../../../../core/models/notification_item.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/responsive_wrap_grid.dart';
import '../providers/home_providers.dart';
import '../widgets/latest_updates_widget.dart';
import '../widgets/quick_actions_section.dart';

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
              _SmartDashboardCards(viewModel: viewModel),
              const SizedBox(height: AppSpacing.lg),
              QuickActionsSection(actions: viewModel.quickActions),
              const SizedBox(height: AppSpacing.lg),
              const _SectionTitle(
                title: 'المطلوب منك الآن',
                subtitle:
                    'أولوية اليوم مرتبة تلقائيًا حسب الاستعجال حتى تعرف ما يستحق التدخل أولًا.',
              ),
              const SizedBox(height: AppSpacing.md),
              ResponsiveWrapGrid(
                minItemWidth: 190,
                spacing: AppSpacing.sm,
                maxColumns: 3,
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
              _HomeResponsiveGrid(
                children: [
                  _TipSection(viewModel: viewModel),
                  _SnapshotSection(viewModel: viewModel),
                  _ActivitySummaryCard(
                    activities: viewModel.courseActivities,
                    notifications: viewModel.notificationsPreview,
                  ),
                  _CourseActivityCard(activities: viewModel.courseActivities),
                  LatestUpdatesWidget(
                    items: viewModel.notificationsPreview,
                    unreadCount: viewModel.unreadCount,
                  ),
                ],
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

class _HomeResponsiveGrid extends StatelessWidget {
  const _HomeResponsiveGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final targetColumns = width > AppBreakpoints.desktop
            ? 3
            : width >= AppBreakpoints.tablet
            ? 2
            : 1;
        final columns = targetColumns.clamp(1, children.length).toInt();
        final spacing = width > AppBreakpoints.desktop
            ? AppSpacing.xl
            : AppSpacing.md;
        final totalSpacing = spacing * (columns - 1);
        final itemWidth = (width - totalSpacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

class _SmartDashboardCards extends StatelessWidget {
  const _SmartDashboardCards({required this.viewModel});

  final StudentHomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapGrid(
      minItemWidth: 180,
      spacing: AppSpacing.sm,
      maxColumns: 5,
      children: [
        _SmartMetricCard(
          icon: Icons.play_lesson_outlined,
          title: 'محاضرات اليوم',
          value: '${viewModel.todayLecturesCount}',
          subtitle: 'ضمن الجدول الحالي',
          color: AppColors.primary,
        ),
        _SmartMetricCard(
          icon: Icons.quiz_outlined,
          title: 'كويزات متاحة',
          value: '${viewModel.availableQuizzesCount}',
          subtitle: 'جاهزة للدخول',
          color: AppColors.error,
        ),
        _SmartMetricCard(
          icon: Icons.campaign_outlined,
          title: 'إعلانات مهمة',
          value: '${viewModel.importantAnnouncementsCount}',
          subtitle: 'غير قابلة للتأجيل',
          color: AppColors.warning,
        ),
        _SmartMetricCard(
          icon: Icons.trending_up_rounded,
          title: 'التقدم العام',
          value: '${(viewModel.overallProgress * 100).round()}%',
          subtitle: 'متوسط موادك',
          color: AppColors.teal,
          progress: viewModel.overallProgress,
        ),
        _SmartMetricCard(
          icon: Icons.grade_outlined,
          title: 'متوسط الدرجات',
          value: '${viewModel.averageGrade.round()}%',
          subtitle: 'تقدير مستمر',
          color: AppColors.success,
          progress: viewModel.averageGrade / 100,
        ),
      ],
    );
  }
}

class _SmartMetricCard extends StatelessWidget {
  const _SmartMetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    this.progress,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: context.appColors.surfaceElevated,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          if (progress != null) ...[
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(
              value: progress!.clamp(0, 1),
              minHeight: 7,
              borderRadius: BorderRadius.circular(999),
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ],
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
              AppAvatar(
                name: viewModel.profile.fullName,
                imageUrl: viewModel.profile.avatarUrl,
                radius: 28,
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
                      'مساحتك الأكاديمية اليومية',
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
                label: 'القسم',
                value: viewModel.profile.department,
              ),
              _HeroInfoTile(label: 'الفرقة', value: viewModel.profile.level),
              _HeroInfoTile(
                label: 'كود الطالب',
                value: viewModel.profile.studentNumber,
              ),
              _HeroInfoTile(
                label: 'المعدل',
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
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Icon(item.icon, size: 18, color: accent),
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
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
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
            variant: AppButtonVariant.secondary,
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

class _ActivitySummaryCard extends StatelessWidget {
  const _ActivitySummaryCard({
    required this.activities,
    required this.notifications,
  });

  final List<CourseActivityItem> activities;
  final List<AppNotificationItem> notifications;

  @override
  Widget build(BuildContext context) {
    final latestActivity = activities.isEmpty ? null : activities.first;
    final latestNotification = notifications.isEmpty
        ? null
        : notifications.first;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('آخر النشاط', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          ResponsiveWrapGrid(
            minItemWidth: 120,
            spacing: AppSpacing.sm,
            maxColumns: 2,
            children: [
              _MetricTile(label: 'داخل المواد', value: '${activities.length}'),
              _MetricTile(label: 'التنبيهات', value: '${notifications.length}'),
            ],
          ),
          if (latestActivity != null) ...[
            const SizedBox(height: AppSpacing.md),
            _ActivityTile(
              title: latestActivity.title,
              subtitle: latestActivity.subjectName,
              description: latestActivity.description,
              meta: latestActivity.createdAtLabel,
              accent: _activityColor(latestActivity.type),
            ),
          ],
          if (latestNotification != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _ActivityTile(
              title: latestNotification.title,
              subtitle:
                  latestNotification.subjectName ?? latestNotification.category,
              description: latestNotification.body,
              meta: latestNotification.createdAtLabel,
              accent: _notificationColor(latestNotification.urgency),
            ),
          ],
        ],
      ),
    );
  }
}

class _CourseActivityCard extends StatelessWidget {
  const _CourseActivityCard({required this.activities});

  final List<CourseActivityItem> activities;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('داخل المواد', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          if (activities.isEmpty)
            Text(
              'لا توجد أنشطة جديدة داخل المواد الآن.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
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
