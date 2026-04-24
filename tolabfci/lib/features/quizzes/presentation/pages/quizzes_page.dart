import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/quiz_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/quizzes_providers.dart';
import '../widgets/quiz_list_tile.dart';

class QuizzesPage extends ConsumerWidget {
  const QuizzesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesAsync = ref.watch(quizzesProvider(null));

    return SafeArea(
      child: AdaptivePageContainer(
        child: quizzesAsync.when(
          data: (quizzes) {
            final openNow = quizzes.where(_isOpen).toList();
            final upcoming = quizzes.where(_isUpcoming).toList();
            final submitted = quizzes
                .where((quiz) => quiz.isSubmitted)
                .toList();
            final ended = quizzes.where(_isEndedNotSubmitted).toList();

            return ListView(
              children: [
                _QuizHero(
                  openCount: openNow.length,
                  upcomingCount: upcoming.length,
                  submittedCount: submitted.length,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (openNow.isEmpty &&
                    upcoming.isEmpty &&
                    submitted.isEmpty &&
                    ended.isEmpty)
                  const EmptyStateWidget(
                    title: 'لا توجد كويزات',
                    subtitle: 'ستظهر الكويزات المفتوحة والقادمة والمنتهية هنا.',
                    icon: Icons.quiz_outlined,
                  )
                else ...[
                  if (openNow.isNotEmpty)
                    _QuizSection(title: 'مفتوح الآن', quizzes: openNow),
                  if (upcoming.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _QuizSection(title: 'قادم', quizzes: upcoming),
                  ],
                  if (submitted.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _QuizSection(title: 'تم التسليم', quizzes: submitted),
                  ],
                  if (ended.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _QuizSection(title: 'منتهي', quizzes: ended),
                  ],
                ],
              ],
            );
          },
          loading: () => const LoadingWidget(label: 'جارٍ تحميل الكويزات...'),
          error: (error, _) => ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }
}

class _QuizHero extends StatelessWidget {
  const _QuizHero({
    required this.openCount,
    required this.upcomingCount,
    required this.submittedCount,
  });

  final int openCount;
  final int upcomingCount;
  final int submittedCount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الكويزات', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'تابع الكويزات المفتوحة والقادمة والمنتهية من صفحة واحدة مع وضوح في الوقت المتبقي وحالة التسليم.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _Metric(
                label: 'مفتوح الآن',
                value: '$openCount',
                color: AppColors.error,
              ),
              _Metric(
                label: 'قادم',
                value: '$upcomingCount',
                color: AppColors.warning,
              ),
              _Metric(
                label: 'تم التسليم',
                value: '$submittedCount',
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuizSection extends StatelessWidget {
  const _QuizSection({required this.title, required this.quizzes});

  final String title;
  final List<QuizItem> quizzes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        ...quizzes.map(
          (quiz) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: QuizListTile(quiz: quiz),
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

bool _isOpen(QuizItem quiz) {
  final now = DateTime.now();
  return !quiz.isSubmitted &&
      quiz.startsAt != null &&
      quiz.closesAt != null &&
      !quiz.startsAt!.isAfter(now) &&
      quiz.closesAt!.isAfter(now);
}

bool _isUpcoming(QuizItem quiz) {
  final startsAt = quiz.startsAt;
  return !quiz.isSubmitted &&
      startsAt != null &&
      startsAt.isAfter(DateTime.now());
}

bool _isEndedNotSubmitted(QuizItem quiz) {
  final closesAt = quiz.closesAt;
  return !quiz.isSubmitted &&
      closesAt != null &&
      closesAt.isBefore(DateTime.now());
}
