import 'package:flutter/material.dart';

import '../../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';
import '../../../../../core/design/app_spacing.dart';
import '../../models/quiz_builder_models.dart';

class QuizBuilderPreviewDialog extends StatelessWidget {
  const QuizBuilderPreviewDialog({
    super.key,
    required this.title,
    required this.description,
    required this.questions,
  });

  final String title;
  final String description;
  final List<QuizBuilderQuestionDraft> questions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ListView(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              for (var index = 0; index < questions.length; index++) ...[
                PreviewQuestion(index: index, question: questions[index]),
                if (index != questions.length - 1)
                  const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class PreviewQuestion extends StatelessWidget {
  const PreviewQuestion({
    super.key,
    required this.index,
    required this.question,
  });

  final int index;
  final QuizBuilderQuestionDraft question;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: DashboardThemeTokens.of(context).border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${index + 1}. ${question.prompt}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (question.options.isEmpty)
            Text(
              question.type == 'paragraph'
                  ? 'Student paragraph response area'
                  : 'Student short answer field',
            )
          else
            ...question.options.map((option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    Icon(
                      question.type == 'checkbox'
                          ? Icons.check_box_outline_blank_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(option),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
