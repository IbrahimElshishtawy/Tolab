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
    required this.sections,
  });

  final SubjectOverview subject;
  final List<TaskItem> tasks;
  final List<QuizItem> quizzes;
  final List<LectureItem> lectures;
  final List<SectionItem> sections;

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
    final nextSection = sections.cast<SectionItem?>().firstWhere(
      (section) => section?.startsAt?.isAfter(now) ?? false,
      orElse: () => null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المطلوب الآن / Required now',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'أقرب محاضرة وسكشن وكويز وتسليم، بدون كروت ضخمة أو مساحة ضائعة.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        ResponsiveWrapGrid(
          minItemWidth: 168,
          spacing: AppSpacing.sm,
          children: [
            _FocusCard(
              title: 'المحاضرة التالية',
              body: nextLecture?.title ?? 'لا توجد محاضرة قريبة الآن',
              meta: nextLecture?.scheduleLabel ?? 'الجدول مستقر حاليًا',
              accent: AppColors.indigo,
              icon: Icons.play_circle_outline_rounded,
            ),
            _FocusCard(
              title: 'السكشن القادم',
              body: nextSection?.title ?? 'لا يوجد سكشن قريب الآن',
              meta: nextSection == null
                  ? 'تابع تبويب السكاشن'
                  : '${nextSection.scheduleLabel} • ${nextSection.isOnline ? 'أونلاين' : 'حضوري'}',
              accent: AppColors.success,
              icon: Icons.co_present_outlined,
            ),
            _FocusCard(
              title: 'الكويز المفتوح',
              body: openQuiz?.title ?? 'لا يوجد كويز مفتوح حاليًا',
              meta: openQuiz?.startAtLabel ?? 'راقب تبويب الكويزات',
              accent: AppColors.error,
              icon: Icons.quiz_outlined,
            ),
            _FocusCard(
              title: 'التسليم المعلق',
              body: requiredTask?.title ?? 'لا يوجد تسليم عاجل الآن',
              meta: requiredTask?.dueDateLabel ?? 'كل التسليمات مستقرة',
              accent: AppColors.warning,
              icon: Icons.assignment_outlined,
            ),
            _FocusCard(
              title: 'آخر نشاط',
              body: subject.lastActivityLabel,
              meta: subject.status,
              accent: AppColors.primary,
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 17, color: accent),
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
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            meta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}
