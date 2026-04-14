import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/quiz_models.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';

class QuizListTile extends StatelessWidget {
  const QuizListTile({super.key, required this.quiz});

  final QuizItem quiz;

  @override
  Widget build(BuildContext context) {
    final status = _quizStatus(quiz);
    final color = switch (status) {
      'مفتوح' => AppColors.error,
      'قريب' => AppColors.warning,
      'تم التسليم' => AppColors.success,
      _ => AppColors.textSecondary,
    };

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.quiz_outlined, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        quiz.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    AppBadge(
                      label: status,
                      backgroundColor: AppColors.surfaceAlt,
                      foregroundColor: color,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  quiz.subjectName ?? quiz.typeLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${quiz.startAtLabel} - ${quiz.durationLabel}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          FilledButton.tonal(
            onPressed: () => context.goNamed(
              RouteNames.quizEntry,
              pathParameters: {'subjectId': quiz.subjectId, 'quizId': quiz.id},
            ),
            child: const Text('عرض'),
          ),
        ],
      ),
    );
  }
}

String _quizStatus(QuizItem quiz) {
  if (quiz.isSubmitted) {
    return 'تم التسليم';
  }

  final now = DateTime.now();
  if (quiz.startsAt != null &&
      quiz.closesAt != null &&
      !quiz.startsAt!.isAfter(now) &&
      quiz.closesAt!.isAfter(now)) {
    return 'مفتوح';
  }
  if (quiz.startsAt != null && quiz.startsAt!.isAfter(now)) {
    return 'قريب';
  }
  return 'منتهي';
}
