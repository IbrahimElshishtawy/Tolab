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
        Text('مطلوب الآن', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'بطاقات ذكية توضح أولويات المادة الحالية حتى لا تضيع التفاصيل المهمة.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        ResponsiveWrapGrid(
          minItemWidth: 220,
          spacing: AppSpacing.sm,
          children: [
            _FocusCard(
              title: 'مطلوب الآن',
              body: requiredTask?.title ?? 'لا توجد عناصر عاجلة الآن',
              accent: AppColors.primary,
            ),
            _FocusCard(
              title: 'كويز مفتوح',
              body: openQuiz?.title ?? 'لا يوجد كويز مفتوح حاليًا',
              accent: AppColors.error,
            ),
            _FocusCard(
              title: 'شيت مطلوب',
              body: requiredTask?.dueDateLabel ?? 'لا يوجد شيت بانتظار التسليم',
              accent: AppColors.warning,
            ),
            _FocusCard(
              title: 'محاضرة قادمة',
              body: nextLecture?.title ?? 'لا توجد محاضرة قريبة الآن',
              accent: AppColors.indigo,
            ),
            _FocusCard(
              title: 'آخر نشاط',
              body: subject.lastActivityLabel,
              accent: AppColors.success,
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
    required this.accent,
  });

  final String title;
  final String body;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBadge(
            label: title,
            backgroundColor: accent.withValues(alpha: 0.12),
            foregroundColor: accent,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
