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
              _SectionTitle(
                title: 'المطلوب منك الآن',
                subtitle:
                    'أولوية اليوم مرتبة تلقائيًا حسب urgency، بحيث تعرف ما الذي يستحق التدخل فورًا.',
              ),
              const SizedBox(height: AppSpacing.md),
              ResponsiveWrapGrid(
                minItemWidth: 250,
                children: [
                  for (final item in viewModel.requiredTodayItems)
                    _RequiredActionCard(item: item),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionTitle(
                title: 'جدولك الدراسي',
                subtitle:
                    'عرض agenda ذكي لما سيحدث اليوم ثم غدًا وهذا الأسبوع.',
              ),
              const SizedBox(height: AppSpacing.md),
              _AgendaSection(groups: viewModel.timelineGroups),
              const SizedBox(height: AppSpacing.lg),
              ResponsiveWrapGrid(
                minItemWidth: 320,
                children: [
                  _SnapshotSection(viewModel: viewModel),
                  _TipSection(viewModel: viewModel),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionTitle(
                title: 'آخر النشاط',
                subtitle:
                    'محاضرات جديدة، كويزات مفتوحة، إعلانات ودرجات مضافة داخل المواد.',
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
    return AppCard(
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.indigo.withValues(alpha: 0.94),
              const Color(0xFF1D2D4A),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحبًا ${viewModel.profile.fullName}',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Smart Student Academic Assistant',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
                AppBadge(
                  label: viewModel.profile.academicStatus,
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                  foregroundColor: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _HeroPill(label: viewModel.profile.department),
                _HeroPill(label: viewModel.profile.level),
                _HeroPill(
                  label: 'الرقم الجامعي ${viewModel.profile.studentNumber}',
                ),
                _HeroPill(
                  label: 'GPA ${viewModel.profile.gpa.toStringAsFixed(2)}',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final action in viewModel.quickActions)
                  AppButton(
                    label: _quickActionLabel(action.type),
                    onPressed: action.target == null
                        ? null
                        : () => _openTarget(context, action.target!),
                    isExpanded: false,
                    icon: _quickActionIcon(action.type),
                    variant: action.type == StudentQuickActionType.openQuiz
                        ? AppButtonVariant.primary
                        : AppButtonVariant.secondary,
                  ),
              ],
            ),
          ],
        ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(item.icon, color: accent),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppBadge(
                  label: _priorityLabel(item.priority),
                  backgroundColor: accent.withValues(alpha: 0.12),
                  foregroundColor: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            item.title,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(item.subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          Text(
            item.meta,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
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
              width: 12,
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
              backgroundColor: Colors.white,
              foregroundColor: accent,
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
            minItemWidth: 140,
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
                        padding: EdgeInsets.only(top: 6),
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
            width: 12,
            height: 60,
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
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

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: Colors.white),
      ),
    );
  }
}

String _quickActionLabel(StudentQuickActionType type) {
  return switch (type) {
    StudentQuickActionType.viewTimetable => 'الجدول',
    StudentQuickActionType.openQuiz => 'فتح كويز',
    StudentQuickActionType.uploadAssignment => 'رفع تكليف',
    StudentQuickActionType.openCourse => 'فتح مادة',
    StudentQuickActionType.checkResults => 'النتائج',
  };
}

IconData _quickActionIcon(StudentQuickActionType type) {
  return switch (type) {
    StudentQuickActionType.viewTimetable => Icons.calendar_month_rounded,
    StudentQuickActionType.openQuiz => Icons.quiz_outlined,
    StudentQuickActionType.uploadAssignment => Icons.upload_file_rounded,
    StudentQuickActionType.openCourse => Icons.menu_book_rounded,
    StudentQuickActionType.checkResults => Icons.bar_chart_rounded,
  };
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
