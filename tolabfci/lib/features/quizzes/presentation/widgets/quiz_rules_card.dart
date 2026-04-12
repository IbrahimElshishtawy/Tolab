import 'package:flutter/material.dart';

import '../../../../core/models/quiz_models.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';

class QuizRulesCard extends StatelessWidget {
  const QuizRulesCard({
    super.key,
    required this.quiz,
  });

  final QuizItem quiz;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(quiz.title, style: Theme.of(context).textTheme.displaySmall),
              ),
              AppBadge(label: quiz.typeLabel),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('${quiz.startAtLabel} • ${quiz.durationLabel}'),
          const SizedBox(height: AppSpacing.lg),
          Text('Entry rules', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          ...quiz.instructions.map(
            (instruction) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(Icons.check_circle_outline_rounded, size: 16),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(instruction)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Secure mode integration point',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'When the mobile secure mode is enabled by the platform team, hook screenshot blocking and app-background handling before starting the actual quiz attempt.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
