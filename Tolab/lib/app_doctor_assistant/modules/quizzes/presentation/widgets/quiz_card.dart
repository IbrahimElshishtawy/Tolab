import 'package:flutter/material.dart';

import '../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';
import '../../../dashboard/presentation/widgets/dashboard_section_primitives.dart';
import '../../../../core/design/app_spacing.dart';
import '../models/quizzes_workspace_models.dart';

class QuizCard extends StatelessWidget {
  const QuizCard({
    super.key,
    required this.quiz,
    required this.onPreview,
    required this.onEdit,
    required this.onPrimaryAction,
    required this.primaryActionLabel,
    required this.onResults,
    required this.onDuplicate,
  });

  final QuizWorkspaceItem quiz;
  final VoidCallback onPreview;
  final VoidCallback onEdit;
  final VoidCallback onPrimaryAction;
  final String primaryActionLabel;
  final VoidCallback onResults;
  final VoidCallback onDuplicate;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: tokens.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: quiz.accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  quiz.subjectCode,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: quiz.accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              DashboardToneBadge(
                label: quiz.statusLabel,
                tone: quiz.statusTone,
              ),
              if (quiz.isOpen)
                const DashboardToneBadge(label: 'Live now', tone: 'danger'),
              if (quiz.startsToday)
                const DashboardToneBadge(label: 'Today', tone: 'warning'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            quiz.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            quiz.subjectLabel,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _MetaChip(
                icon: Icons.play_circle_outline_rounded,
                label: quiz.startLabel,
              ),
              _MetaChip(icon: Icons.stop_circle_outlined, label: quiz.endLabel),
              _MetaChip(icon: Icons.timer_outlined, label: quiz.durationLabel),
              _MetaChip(
                icon: Icons.quiz_outlined,
                label: '${quiz.questionCount} questions',
              ),
              _MetaChip(
                icon: Icons.workspace_premium_rounded,
                label: '${quiz.totalMarks} marks',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            quiz.description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _MiniInfo(
                label: 'Students',
                value: '${quiz.totalStudents} total',
              ),
              _MiniInfo(
                label: 'Entered',
                value: '${quiz.enteredStudents} entered',
              ),
              _MiniInfo(
                label: 'Not started',
                value: '${quiz.notStartedStudents} pending',
              ),
              _MiniInfo(
                label: 'Attempts',
                value: '${quiz.attemptsAllowed} allowed',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Completion ${(quiz.completionRatio * 100).round()}%',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    quiz.timeRemainingLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: quiz.isOpen ? tokens.danger : tokens.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: quiz.completionRatio,
                  minHeight: 8,
                  backgroundColor: tokens.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    quiz.isOpen ? tokens.danger : quiz.accentColor,
                  ),
                ),
              ),
            ],
          ),
          if (quiz.isOpen) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: tokens.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: tokens.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.monitor_heart_rounded,
                    color: tokens.danger,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '${quiz.liveParticipants} students are inside the quiz right now.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.tonalIcon(
                onPressed: onPreview,
                icon: const Icon(Icons.preview_rounded, size: 18),
                label: const Text('Preview'),
              ),
              FilledButton.tonalIcon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Edit'),
              ),
              FilledButton.tonalIcon(
                onPressed: onPrimaryAction,
                icon: Icon(
                  quiz.isOpen
                      ? Icons.stop_circle_rounded
                      : Icons.publish_rounded,
                  size: 18,
                ),
                label: Text(primaryActionLabel),
              ),
              FilledButton.tonalIcon(
                onPressed: onResults,
                icon: const Icon(Icons.bar_chart_rounded, size: 18),
                label: const Text('Results'),
              ),
              FilledButton.tonalIcon(
                onPressed: onDuplicate,
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Duplicate'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tokens.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 220),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: tokens.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
