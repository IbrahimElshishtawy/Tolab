import 'package:flutter/material.dart';

import '../../../../core/models/quiz_models.dart';
import '../../../../core/models/subject_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/responsive_wrap_grid.dart';

class SubjectRequiredNowSection extends StatelessWidget {
  const SubjectRequiredNowSection({
    super.key,
    required this.subject,
    required this.tasks,
    required this.quizzes,
    required this.lectures,
  });

  final SubjectOverview subject;
  final List<TaskItem> tasks;
  final List<QuizItem> quizzes;
  final List<LectureItem> lectures;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final openQuiz = quizzes.cast<QuizItem?>().firstWhere(
      (quiz) =>
          quiz != null &&
          quiz.startsAt != null &&
          quiz.closesAt != null &&
          !quiz.startsAt!.isAfter(now) &&
          quiz.closesAt!.isAfter(now) &&
          !quiz.isSubmitted,
      orElse: () => null,
    );
    final requiredTask = tasks.cast<TaskItem?>().firstWhere(
      (task) => task != null && !task.isCompleted,
      orElse: () => null,
    );
    final nextLecture = lectures.cast<LectureItem?>().firstWhere(
      (lecture) => lecture?.startsAt?.isAfter(now) ?? false,
      orElse: () => null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('المطلوب الآن', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'نظرة سريعة على أقرب ما يحتاج منك تدخلاً داخل هذه المادة.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        ResponsiveWrapGrid(
          minItemWidth: 180,
          spacing: AppSpacing.sm,
          children: [
            _FocusCard(
              title: 'تكليف',
              body: requiredTask?.title ?? 'لا يوجد عنصر عاجل الآن',
              meta: requiredTask?.dueDateLabel ?? subject.lastActivityLabel,
              accent: AppColors.primary,
              icon: Icons.assignment_outlined,
            ),
            _FocusCard(
              title: 'كويز',
              body: openQuiz?.title ?? 'لا يوجد كويز مفتوح حاليًا',
              meta: openQuiz?.startAtLabel ?? 'راقب تبويب الكويزات للمستجدات',
              accent: AppColors.error,
              icon: Icons.quiz_outlined,
            ),
            _FocusCard(
              title: 'محاضرة',
              body: nextLecture?.title ?? 'لا توجد محاضرة قريبة الآن',
              meta: nextLecture?.scheduleLabel ?? 'الجدول مستقر حاليًا',
              accent: AppColors.indigo,
              icon: Icons.play_circle_outline_rounded,
            ),
            _FocusCard(
              title: 'آخر نشاط',
              body: subject.lastActivityLabel,
              meta: subject.status,
              accent: AppColors.success,
              icon: Icons.bolt_rounded,
            ),
          ],
        ),
      ],
    );
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard({
    required this.title,
    required this.body,
    required this.meta,
    required this.accent,
    required this.icon,
  });

  final String title;
  final String body;
  final String meta;
  final Color accent;
  final IconData icon;

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
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppBadge(
                  label: title,
                  backgroundColor: accent.withValues(alpha: 0.12),
                  foregroundColor: accent,
                  dense: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(meta, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
