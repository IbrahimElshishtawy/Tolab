import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/quiz_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/quiz_action_providers.dart';
import '../providers/quizzes_providers.dart';

class QuizEntryPage extends ConsumerStatefulWidget {
  const QuizEntryPage({
    super.key,
    required this.subjectId,
    required this.quizId,
  });

  final String subjectId;
  final String quizId;

  @override
  ConsumerState<QuizEntryPage> createState() => _QuizEntryPageState();
}

class _QuizEntryPageState extends ConsumerState<QuizEntryPage> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final quizzesAsync = ref.watch(quizzesProvider(widget.subjectId));

    return SafeArea(
      child: AdaptivePageContainer(
        child: quizzesAsync.when(
          data: (quizzes) {
            final quiz = quizzes.firstWhere((item) => item.id == widget.quizId);
            final statusLabel = _statusLabel(quiz);
            final canStart = _canStartQuiz(quiz);
            final questionCount =
                quiz.questionCount ?? _fallbackQuestionCount(quiz.id);

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
                                  quiz.subjectName ?? '',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ],
                            ),
                          ),
                          AppBadge(
                            label: statusLabel,
                            backgroundColor: _statusColor(
                              statusLabel,
                            ).withValues(alpha: 0.12),
                            foregroundColor: _statusColor(statusLabel),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          AppBadge(
                            label: quiz.startAtLabel,
                            backgroundColor: Colors.white,
                          ),
                          AppBadge(
                            label: quiz.durationLabel,
                            backgroundColor: Colors.white,
                          ),
                          AppBadge(
                            label: quiz.isOnline ? 'أونلاين' : 'حضوري',
                            backgroundColor: Colors.white,
                          ),
                          AppBadge(
                            label: '$questionCount سؤال',
                            backgroundColor: Colors.white,
                          ),
                          AppBadge(
                            label:
                                'المحاولات ${quiz.attemptsUsed}/${quiz.maxAttempts}',
                            backgroundColor: Colors.white,
                          ),
                        ],
                      ),
                      if (quiz.description != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          quiz.description!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'التعليمات',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ...quiz.instructions.map(
                        (instruction) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(child: Text(instruction)),
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
                        'حالة التسليم',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        quiz.isSubmitted
                            ? (quiz.submissionStateLabel ?? 'تم التسليم بنجاح')
                            : _remainingLabel(quiz),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _statusColor(statusLabel),
                        ),
                      ),
                      if (quiz.scoreLabel != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'النتيجة ${quiz.scoreLabel}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: quiz.isSubmitted
                            ? 'تم تسليم الكويز'
                            : 'ابدأ الكويز',
                        onPressed:
                            (!canStart || _isSubmitting || quiz.isSubmitted)
                            ? null
                            : () async {
                                final messenger = ScaffoldMessenger.of(context);
                                setState(() => _isSubmitting = true);
                                await ref
                                    .read(quizActionsProvider)
                                    .submitQuiz(
                                      quiz.id,
                                      subjectId: widget.subjectId,
                                    );
                                if (!mounted) {
                                  return;
                                }
                                setState(() => _isSubmitting = false);
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'تم تسجيل محاولة الكويز وتسليمه تجريبيًا بنجاح.',
                                    ),
                                  ),
                                );
                              },
                        icon: Icons.play_arrow_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () =>
              const LoadingWidget(label: 'جارٍ تحميل بيانات الكويز...'),
          error: (error, _) => ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }
}

bool _canStartQuiz(QuizItem quiz) {
  final now = DateTime.now();
  return quiz.startsAt != null &&
      quiz.closesAt != null &&
      !quiz.startsAt!.isAfter(now) &&
      quiz.closesAt!.isAfter(now);
}

String _statusLabel(QuizItem quiz) {
  if (quiz.isSubmitted) {
    return 'تم التسليم';
  }
  final now = DateTime.now();
  if (_canStartQuiz(quiz)) {
    return 'مفتوح';
  }
  if (quiz.startsAt != null && quiz.startsAt!.isAfter(now)) {
    return 'قريب';
  }
  return 'منتهي';
}

String _remainingLabel(QuizItem quiz) {
  if (quiz.isSubmitted) {
    return 'تم الانتهاء';
  }
  if (_canStartQuiz(quiz)) {
    return 'يغلق ${formatTimeUntilArabic(quiz.closesAt)}';
  }
  if (quiz.startsAt != null && quiz.startsAt!.isAfter(DateTime.now())) {
    return 'يبدأ ${formatTimeUntilArabic(quiz.startsAt)}';
  }
  return 'هذا الكويز غير متاح الآن';
}

int _fallbackQuestionCount(String quizId) {
  switch (quizId) {
    case 'quiz-1':
      return 12;
    case 'quiz-2':
      return 20;
    case 'quiz-3':
      return 10;
    default:
      return 10;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'مفتوح':
      return AppColors.error;
    case 'قريب':
      return AppColors.warning;
    case 'تم التسليم':
      return AppColors.success;
    default:
      return AppColors.textSecondary;
  }
}
