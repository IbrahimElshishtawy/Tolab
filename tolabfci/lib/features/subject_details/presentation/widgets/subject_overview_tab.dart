import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/quiz_models.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/responsive_wrap_grid.dart';
import '../../../quizzes/presentation/providers/quizzes_providers.dart';
import '../../../subjects/presentation/providers/subjects_providers.dart';

class SubjectOverviewTab extends ConsumerWidget {
  const SubjectOverviewTab({
    super.key,
    required this.subjectId,
    this.usePageScroll = false,
  });

  final String subjectId;
  final bool usePageScroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectAsync = ref.watch(subjectByIdProvider(subjectId));
    final lectures = ref.watch(lecturesProvider(subjectId)).value ?? [];
    final sections = ref.watch(sectionsProvider(subjectId)).value ?? [];
    final tasks = ref.watch(tasksProvider(subjectId)).value ?? [];
    final quizzes = ref.watch(quizzesProvider(subjectId)).value ?? [];

    return subjectAsync.when(
      data: (subject) {
        final openQuizzes = quizzes.where(_isQuizOpen).length;
        final completedTasks = tasks.where((task) => task.isCompleted).length;
        final latestItems = <_OverviewActionItem>[
          ...lectures
              .take(2)
              .map(
                (lecture) => _OverviewActionItem(
                  icon: Icons.play_circle_outline_rounded,
                  title: lecture.title,
                  subtitle: lecture.scheduleLabel,
                  accent: AppColors.primary,
                  onTap: () => _showDetailsSheet(
                    context,
                    title: lecture.title,
                    lines: [
                      lecture.subjectName ?? subject.name,
                      lecture.instructorName ?? subject.instructor,
                      lecture.locationLabel ?? 'Tolab Meet',
                      lecture.isOnline ? 'محاضرة أونلاين' : 'محاضرة حضورية',
                    ],
                  ),
                ),
              ),
          ...quizzes
              .take(2)
              .map(
                (quiz) => _OverviewActionItem(
                  icon: Icons.quiz_outlined,
                  title: quiz.title,
                  subtitle: quiz.startAtLabel,
                  accent: _quizColor(quiz),
                  onTap: () => context.goNamed(
                    RouteNames.quizEntry,
                    pathParameters: {
                      'subjectId': quiz.subjectId,
                      'quizId': quiz.id,
                    },
                  ),
                ),
              ),
          ...tasks
              .take(2)
              .map(
                (task) => _OverviewActionItem(
                  icon: Icons.assignment_outlined,
                  title: task.title,
                  subtitle: task.dueDateLabel,
                  accent: task.isCompleted
                      ? AppColors.success
                      : AppColors.warning,
                  onTap: () => context.goNamed(
                    RouteNames.assignmentUpload,
                    pathParameters: {
                      'subjectId': task.subjectId,
                      'taskId': task.id,
                    },
                  ),
                ),
              ),
        ];

        return ListView(
          shrinkWrap: usePageScroll,
          physics: usePageScroll ? const NeverScrollableScrollPhysics() : null,
          children: [
            AppCard(
              backgroundColor: context.appColors.surfaceElevated,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'نظرة عامة على المادة',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(subject.description),
                  const SizedBox(height: AppSpacing.md),
                  LinearProgressIndicator(
                    value: subject.progress,
                    minHeight: 9,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ResponsiveWrapGrid(
                    minItemWidth: 130,
                    spacing: AppSpacing.sm,
                    children: [
                      _OverviewMetric(
                        label: 'المحاضرات',
                        value: '${lectures.length}/${subject.lecturesCount}',
                      ),
                      _OverviewMetric(
                        label: 'السكاشن',
                        value: '${sections.length}/${subject.sectionsCount}',
                      ),
                      _OverviewMetric(
                        label: 'كويزات مفتوحة',
                        value: '$openQuizzes',
                      ),
                      _OverviewMetric(
                        label: 'تسليمات مكتملة',
                        value: '$completedTasks/${tasks.length}',
                      ),
                      _OverviewMetric(
                        label: 'تقدمك',
                        value: '${(subject.progress * 100).round()}%',
                      ),
                      const _OverviewMetric(label: 'درجة حالية', value: '88%'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'آخر نشاط داخل المادة',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subject.lastActivityLabel,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...latestItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _OverviewActionTile(item: item),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const AppCard(child: LinearProgressIndicator()),
      error: (error, _) => AppCard(child: Text(error.toString())),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.appColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.border),
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
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _OverviewActionItem {
  const _OverviewActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;
}

class _OverviewActionTile extends StatelessWidget {
  const _OverviewActionTile({required this.item});

  final _OverviewActionItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: context.appColors.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appColors.border),
        ),
        child: Row(
          children: [
            Icon(item.icon, color: item.accent),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left_rounded),
          ],
        ),
      ),
    );
  }
}

bool _isQuizOpen(QuizItem quiz) {
  final now = DateTime.now();
  return !quiz.isSubmitted &&
      quiz.startsAt != null &&
      quiz.closesAt != null &&
      !quiz.startsAt!.isAfter(now) &&
      quiz.closesAt!.isAfter(now);
}

Color _quizColor(QuizItem quiz) {
  if (quiz.isSubmitted) {
    return AppColors.success;
  }
  if (_isQuizOpen(quiz)) {
    return AppColors.error;
  }
  if (quiz.startsAt?.isAfter(DateTime.now()) ?? false) {
    return AppColors.warning;
  }
  return AppColors.support;
}

void _showDetailsSheet(
  BuildContext context, {
  required String title,
  required List<String> lines,
}) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppBadge(label: line),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'إغلاق',
            onPressed: () => Navigator.of(context).pop(),
            variant: AppButtonVariant.secondary,
          ),
        ],
      ),
    ),
  );
}
