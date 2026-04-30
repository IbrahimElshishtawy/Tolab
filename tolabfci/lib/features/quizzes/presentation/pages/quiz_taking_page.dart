import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/quiz_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/quiz_action_providers.dart';
import '../providers/quizzes_providers.dart';

class QuizTakingPage extends ConsumerStatefulWidget {
  const QuizTakingPage({
    super.key,
    required this.subjectId,
    required this.quizId,
  });

  final String subjectId;
  final String quizId;

  @override
  ConsumerState<QuizTakingPage> createState() => _QuizTakingPageState();
}

class _QuizTakingPageState extends ConsumerState<QuizTakingPage> {
  final Map<String, Object?> _answers = {};
  Timer? _timer;
  int _remainingSeconds = 0;
  int _currentQuestionIndex = 0;
  final Set<String> _markedForReview = {};
  bool _submitted = false;
  String? _scoreLabel;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(
      quizDetailsProvider((subjectId: widget.subjectId, quizId: widget.quizId)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('أداء الكويز')),
      body: SafeArea(
        child: AdaptivePageContainer(
          child: detailsAsync.when(
            data: (details) {
              _startTimerIfNeeded(details.quiz.durationMinutes ?? 20);

              if (_submitted) {
                return _SubmittedState(
                  scoreLabel: _scoreLabel,
                  answersCount: _answers.length,
                  reviewAllowed: details.quiz.reviewAllowed,
                );
              }

              final question = details.questions[_currentQuestionIndex];
              final isDesktop = MediaQuery.sizeOf(context).width >= 1100;

              final questionNavigator = AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التقدم',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    LinearProgressIndicator(
                      value:
                          (_currentQuestionIndex + 1) /
                          details.questions.length,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: details.questions.asMap().entries.map((entry) {
                        final selected = entry.key == _currentQuestionIndex;
                        final answered = _answers.containsKey(entry.value.id);
                        final marked = _markedForReview.contains(
                          entry.value.id,
                        );
                        return OutlinedButton(
                          onPressed: () =>
                              setState(() => _currentQuestionIndex = entry.key),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: selected
                                ? AppColors.primary.withValues(alpha: 0.12)
                                : marked
                                ? AppColors.warning.withValues(alpha: 0.12)
                                : answered
                                ? AppColors.success.withValues(alpha: 0.10)
                                : null,
                          ),
                          child: Text('${entry.key + 1}'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );

              final questionCard = AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppBadge(label: 'السؤال ${_currentQuestionIndex + 1}'),
                        const SizedBox(width: AppSpacing.sm),
                        AppBadge(label: '${question.points} درجة'),
                        const Spacer(),
                        AppBadge(
                          label: _formatDuration(_remainingSeconds),
                          backgroundColor: AppColors.error.withValues(
                            alpha: 0.12,
                          ),
                          foregroundColor: AppColors.error,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      question.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (question.description != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(question.description!),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    _QuestionAnswerView(
                      question: question,
                      value: _answers[question.id],
                      onChanged: (value) => setState(() {
                        _answers[question.id] = value;
                      }),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () => setState(() {
                            if (_markedForReview.contains(question.id)) {
                              _markedForReview.remove(question.id);
                            } else {
                              _markedForReview.add(question.id);
                            }
                          }),
                          icon: Icon(
                            _markedForReview.contains(question.id)
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                          ),
                          label: Text(
                            _markedForReview.contains(question.id)
                                ? 'إزالة المراجعة'
                                : 'تحديد للمراجعة',
                          ),
                        ),
                        FilledButton.tonal(
                          onPressed: _currentQuestionIndex == 0
                              ? null
                              : () => setState(() => _currentQuestionIndex--),
                          child: const Text('السابق'),
                        ),
                        FilledButton.tonal(
                          onPressed:
                              _currentQuestionIndex ==
                                  details.questions.length - 1
                              ? null
                              : () => setState(() => _currentQuestionIndex++),
                          child: const Text('التالي'),
                        ),
                        FilledButton.icon(
                          onPressed: () => _confirmSubmit(details.quiz),
                          icon: const Icon(Icons.send_rounded),
                          label: const Text('إرسال الكويز'),
                        ),
                      ],
                    ),
                  ],
                ),
              );

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 280, child: questionNavigator),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(child: questionCard),
                  ],
                );
              }

              return ListView(
                children: [
                  questionNavigator,
                  const SizedBox(height: AppSpacing.lg),
                  questionCard,
                ],
              );
            },
            loading: () => const LoadingWidget(label: 'جارٍ تجهيز الكويز...'),
            error: (error, _) => ErrorStateWidget(message: error.toString()),
          ),
        ),
      ),
    );
  }

  void _startTimerIfNeeded(int durationMinutes) {
    if (_timer != null) {
      return;
    }

    _remainingSeconds = durationMinutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _remainingSeconds = 0;
        unawaited(_submitQuiz());
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  Future<void> _confirmSubmit(QuizItem quiz) async {
    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإرسال'),
        content: const Text('هل تريد إرسال إجاباتك الآن؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('رجوع'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('إرسال'),
          ),
        ],
      ),
    );

    if (shouldSubmit == true) {
      await _submitQuiz();
    }
  }

  Future<void> _submitQuiz() async {
    final updated = await ref
        .read(quizActionsProvider)
        .submitQuiz(
          widget.quizId,
          subjectId: widget.subjectId,
          answers: Map<String, Object?>.from(_answers),
        );
    if (!mounted) {
      return;
    }
    _timer?.cancel();
    setState(() {
      _submitted = true;
      _scoreLabel = updated.scoreLabel;
    });
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remain = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remain';
  }
}

class _QuestionAnswerView extends StatelessWidget {
  const _QuestionAnswerView({
    required this.question,
    required this.value,
    required this.onChanged,
  });

  final QuizQuestion question;
  final Object? value;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    switch (question.type) {
      case QuizQuestionType.mcq:
      case QuizQuestionType.trueFalse:
        return Column(
          children: question.options.map((option) {
            final isSelected = (value as String?) == option.id;
            return InkWell(
              onTap: () => onChanged(option.id),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : context.appColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : context.appColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: isSelected ? AppColors.primary : null,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(option.label)),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      case QuizQuestionType.checkbox:
        final values = Set<String>.from(value as List<String>? ?? const []);
        return Column(
          children: question.options.map((option) {
            return CheckboxListTile(
              value: values.contains(option.id),
              onChanged: (selected) {
                final updated = Set<String>.from(values);
                if (selected == true) {
                  updated.add(option.id);
                } else {
                  updated.remove(option.id);
                }
                onChanged(updated.toList());
              },
              title: Text(option.label),
            );
          }).toList(),
        );
      case QuizQuestionType.shortAnswer:
        return TextFormField(
          initialValue: value as String? ?? '',
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'اكتب إجابتك',
            alignLabelWithHint: true,
          ),
          onChanged: onChanged,
        );
    }
  }
}

class _SubmittedState extends StatelessWidget {
  const _SubmittedState({
    required this.scoreLabel,
    required this.answersCount,
    required this.reviewAllowed,
  });

  final String? scoreLabel;
  final int answersCount;
  final bool reviewAllowed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تم إرسال الكويز',
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(color: AppColors.success),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('تم حفظ $answersCount إجابة وإرسال المحاولة بنجاح.'),
              if (scoreLabel != null) ...[
                const SizedBox(height: AppSpacing.md),
                AppBadge(
                  label: 'النتيجة $scoreLabel',
                  backgroundColor: AppColors.success.withValues(alpha: 0.12),
                  foregroundColor: AppColors.success,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              AppBadge(
                label: reviewAllowed
                    ? 'المراجعة متاحة من صفحة التفاصيل'
                    : 'المراجعة غير متاحة حاليًا',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
