import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/quiz_models.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/quiz_action_providers.dart';
import '../providers/quizzes_providers.dart';
import '../widgets/quiz_rules_card.dart';

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
            final remainingLabel = _remainingLabel(quiz);
            final canStart = _canStartQuiz(quiz);

            return ListView(
              children: [
                QuizRulesCard(
                  quiz: quiz,
                  statusLabel: statusLabel,
                  remainingLabel: remainingLabel,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: quiz.isSubmitted ? 'تم إرسال الكويز' : 'ابدأ الكويز',
                  onPressed: (!canStart || _isSubmitting || quiz.isSubmitted)
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          setState(() => _isSubmitting = true);
                          await ref
                              .read(quizActionsProvider)
                              .submitQuiz(quiz.id, subjectId: widget.subjectId);
                          if (!mounted) {
                            return;
                          }
                          setState(() => _isSubmitting = false);
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('تم تسجيل دخولك للكويز وتسليمه تجريبيًا بنجاح.'),
                            ),
                          );
                        },
                ),
                if (!canStart && !quiz.isSubmitted) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    statusLabel == 'قريب'
                        ? 'زر البدء سيتاح عند فتح الكويز في موعده.'
                        : 'هذا الكويز غير متاح الآن.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            );
          },
          loading: () => const LoadingWidget(label: 'جاري تحميل بيانات الكويز...'),
          error: (error, stackTrace) => ErrorStateWidget(message: error.toString()),
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
  final now = DateTime.now();
  if (_canStartQuiz(quiz)) {
    return formatTimeUntilArabic(quiz.closesAt, reference: now);
  }
  if (quiz.startsAt != null && quiz.startsAt!.isAfter(now)) {
    return formatTimeUntilArabic(quiz.startsAt, reference: now);
  }
  return 'انتهى';
}
