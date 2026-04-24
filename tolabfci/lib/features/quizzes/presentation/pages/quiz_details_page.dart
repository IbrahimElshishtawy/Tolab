import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/quiz_models.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/responsive_wrap_grid.dart';
import '../providers/quizzes_providers.dart';

class QuizDetailsPage extends ConsumerWidget {
  const QuizDetailsPage({
    super.key,
    required this.subjectId,
    required this.quizId,
  });

  final String subjectId;
  final String quizId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(
      quizDetailsProvider((subjectId: subjectId, quizId: quizId)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الكويز')),
      body: SafeArea(
        child: AdaptivePageContainer(
          child: detailsAsync.when(
            data: (details) {
              final quiz = details.quiz;
              final canStart = _canStartQuiz(quiz);
              return ListView(
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    quiz.title,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.displaySmall,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    quiz.subjectName ?? 'المادة',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            AppBadge(
                              label: details.availableStatusLabel,
                              backgroundColor: _statusColor(
                                details.quiz,
                              ).withValues(alpha: 0.12),
                              foregroundColor: _statusColor(details.quiz),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          details.overview ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ResponsiveWrapGrid(
                          minItemWidth: 180,
                          spacing: AppSpacing.sm,
                          children: [
                            _QuizInfoCard(
                              label: 'عدد الأسئلة',
                              value: '${details.questions.length}',
                            ),
                            _QuizInfoCard(
                              label: 'المدة',
                              value: quiz.durationMinutes == null
                                  ? quiz.durationLabel
                                  : '${quiz.durationMinutes} دقيقة',
                            ),
                            _QuizInfoCard(
                              label: 'المحاولات',
                              value: details.attemptsLabel,
                            ),
                            _QuizInfoCard(
                              label: 'الحالة',
                              value: quiz.isSubmitted
                                  ? (quiz.submissionStateLabel ?? 'تم التسليم')
                                  : details.availableStatusLabel,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            FilledButton.icon(
                              onPressed: canStart
                                  ? () => context.goNamed(
                                      RouteNames.quizTaking,
                                      pathParameters: {
                                        'subjectId': subjectId,
                                        'quizId': quizId,
                                      },
                                    )
                                  : null,
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('ابدأ الكويز'),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: null,
                              icon: const Icon(Icons.rule_folder_outlined),
                              label: Text(
                                quiz.reviewAllowed
                                    ? 'المراجعة متاحة'
                                    : 'المراجعة غير متاحة',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'التعليمات والقواعد',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ...details.rules.map(
                          (rule) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 3),
                                  child: Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(child: Text(rule)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'معاينة الأسئلة',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ...details.questions.asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: _QuestionPreviewCard(
                              index: entry.key + 1,
                              question: entry.value,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () =>
                const LoadingWidget(label: 'جارٍ تحميل تفاصيل الكويز...'),
            error: (error, _) => ErrorStateWidget(message: error.toString()),
          ),
        ),
      ),
    );
  }
}

class _QuizInfoCard extends StatelessWidget {
  const _QuizInfoCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
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

class _QuestionPreviewCard extends StatelessWidget {
  const _QuestionPreviewCard({required this.index, required this.question});

  final int index;
  final QuizQuestion question;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppBadge(label: 'سؤال $index'),
              const SizedBox(width: AppSpacing.sm),
              AppBadge(label: '${question.points} درجة'),
              const Spacer(),
              AppBadge(label: _typeLabel(question.type)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(question.title, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

bool _canStartQuiz(QuizItem quiz) {
  final now = DateTime.now();
  return !quiz.isSubmitted &&
      quiz.startsAt != null &&
      quiz.closesAt != null &&
      !quiz.startsAt!.isAfter(now) &&
      quiz.closesAt!.isAfter(now);
}

Color _statusColor(QuizItem quiz) {
  if (quiz.isSubmitted) {
    return AppColors.success;
  }
  if (_canStartQuiz(quiz)) {
    return AppColors.error;
  }
  if (quiz.startsAt != null && quiz.startsAt!.isAfter(DateTime.now())) {
    return AppColors.warning;
  }
  return AppColors.support;
}

String _typeLabel(QuizQuestionType type) {
  switch (type) {
    case QuizQuestionType.mcq:
      return 'اختيار واحد';
    case QuizQuestionType.trueFalse:
      return 'صح أو خطأ';
    case QuizQuestionType.checkbox:
      return 'متعدد';
    case QuizQuestionType.shortAnswer:
      return 'إجابة قصيرة';
  }
}
