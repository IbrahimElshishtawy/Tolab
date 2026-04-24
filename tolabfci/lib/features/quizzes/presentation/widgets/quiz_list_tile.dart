import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/quiz_models.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.quiz_outlined, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      quiz.subjectName ?? quiz.typeLabel,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
              AppBadge(
                label: status,
                backgroundColor: color.withValues(alpha: 0.12),
                foregroundColor: color,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _MetaPill(label: quiz.startAtLabel),
              _MetaPill(label: quiz.durationLabel),
              _MetaPill(label: quiz.isOnline ? 'أونلاين' : 'حضوري'),
              _MetaPill(label: _remainingLabel(quiz)),
            ],
          ),
          if (quiz.description != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              quiz.description!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppButton(
                label: status == 'مفتوح' ? 'دخول الكويز' : 'عرض التفاصيل',
                onPressed: () => context.goNamed(
                  RouteNames.quizEntry,
                  pathParameters: {
                    'subjectId': quiz.subjectId,
                    'quizId': quiz.id,
                  },
                ),
                isExpanded: false,
                icon: status == 'مفتوح'
                    ? Icons.play_arrow_rounded
                    : Icons.visibility_rounded,
              ),
              if (quiz.scoreLabel != null)
                AppBadge(
                  label: quiz.scoreLabel!,
                  backgroundColor: AppColors.success.withValues(alpha: 0.12),
                  foregroundColor: AppColors.success,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.appColors.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
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

String _remainingLabel(QuizItem quiz) {
  if (quiz.isSubmitted) {
    return 'تم الإنهاء';
  }
  if (_quizStatus(quiz) == 'مفتوح') {
    return 'المتبقي ${formatTimeUntilArabic(quiz.closesAt)}';
  }
  if (_quizStatus(quiz) == 'قريب') {
    return 'يبدأ ${formatTimeUntilArabic(quiz.startsAt)}';
  }
  return 'مغلق';
}
