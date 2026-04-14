import 'package:flutter/material.dart';

import '../../../../core/models/quiz_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_section_header.dart';

class QuizRulesCard extends StatelessWidget {
  const QuizRulesCard({
    super.key,
    required this.quiz,
    required this.statusLabel,
    required this.remainingLabel,
  });

  final QuizItem quiz;
  final String statusLabel;
  final String remainingLabel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppSectionHeader(
                  title: quiz.title,
                  subtitle: quiz.subjectName ?? quiz.typeLabel,
                ),
              ),
              AppBadge(
                label: statusLabel,
                backgroundColor: AppColors.surfaceAlt,
                foregroundColor: statusLabel == 'مفتوح'
                    ? AppColors.error
                    : AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppBadge(label: 'البداية: ${quiz.startAtLabel}'),
              AppBadge(
                label: 'المدة: ${quiz.durationLabel}',
                backgroundColor: Colors.white,
              ),
              AppBadge(
                label: 'المتبقي: $remainingLabel',
                backgroundColor: Colors.white,
              ),
              AppBadge(
                label: 'المحاولات: ${quiz.attemptsUsed}/${quiz.maxAttempts}',
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
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'التعليمات',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...quiz.instructions.map(
            (instruction) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.check_circle_outline_rounded, size: 18),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(instruction)),
                ],
              ),
            ),
          ),
          if (quiz.submissionStateLabel != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.18),
                ),
              ),
              child: Text(
                '${quiz.submissionStateLabel}${quiz.scoreLabel == null ? '' : ' - ${quiz.scoreLabel}'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
