import 'package:flutter/material.dart';

import '../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';
import '../../../dashboard/presentation/widgets/dashboard_section_primitives.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/state/async_state.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../presentation/widgets/empty_state_widget.dart';
import '../models/quizzes_workspace_models.dart';
import 'quiz_card.dart';

class QuizzesOverviewPanel extends StatelessWidget {
  const QuizzesOverviewPanel({
    super.key,
    required this.data,
    required this.status,
    required this.errorMessage,
    required this.onRetry,
    required this.onCreateQuiz,
    required this.onPreviewQuiz,
    required this.onEditQuiz,
    required this.onPrimaryAction,
    required this.onResultsQuiz,
    required this.onDuplicateQuiz,
  });

  final QuizzesWorkspaceData data;
  final ViewStatus status;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onCreateQuiz;
  final ValueChanged<QuizWorkspaceItem> onPreviewQuiz;
  final ValueChanged<QuizWorkspaceItem> onEditQuiz;
  final ValueChanged<QuizWorkspaceItem> onPrimaryAction;
  final ValueChanged<QuizWorkspaceItem> onResultsQuiz;
  final ValueChanged<QuizWorkspaceItem> onDuplicateQuiz;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return DashboardSectionCard(
      title: 'Existing Quizzes',
      subtitle:
          'A management board for live monitoring, draft review, quiz windows, and results access.',
      trailing: DashboardToneBadge(
        label: data.healthLabel,
        tone: data.healthTone,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _QuizHighlights(data: data),
          const SizedBox(height: AppSpacing.xl),
          _SectionLabel(title: 'Quick Insights', subtitle: data.healthSummary),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: data.quickInsights
                .map((item) => _InsightCard(label: item))
                .toList(growable: false),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.xl),
          const _SectionLabel(
            title: 'Quiz List View',
            subtitle:
                'Each quiz card exposes status, timing, participation, completion, and fast actions.',
          ),
          const SizedBox(height: AppSpacing.md),
          if (status == ViewStatus.loading && data.quizzes.isEmpty)
            const LoadingStateView(lines: 4)
          else if (status == ViewStatus.failure && data.quizzes.isEmpty)
            ErrorStateView(
              message: errorMessage ?? 'Unable to load quizzes right now.',
              onRetry: onRetry,
            )
          else if (data.quizzes.isEmpty)
            EmptyStateWidget(
              title: 'Start by creating the first quiz',
              subtitle:
                  'Build the first assessment, publish it when ready, and monitor student progress from one place.',
              actionLabel: 'Add Quiz',
              onAction: onCreateQuiz,
              icon: Icons.quiz_rounded,
            )
          else
            Column(
              children: [
                for (var index = 0; index < data.quizzes.length; index++) ...[
                  QuizCard(
                    quiz: data.quizzes[index],
                    onPreview: () => onPreviewQuiz(data.quizzes[index]),
                    onEdit: () => onEditQuiz(data.quizzes[index]),
                    onPrimaryAction: () => onPrimaryAction(data.quizzes[index]),
                    primaryActionLabel: data.quizzes[index].isOpen
                        ? 'Close Quiz'
                        : 'Publish',
                    onResults: () => onResultsQuiz(data.quizzes[index]),
                    onDuplicate: () => onDuplicateQuiz(data.quizzes[index]),
                  ),
                  if (index != data.quizzes.length - 1)
                    const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          const SizedBox(height: AppSpacing.xl),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.xl),
          const _SectionLabel(
            title: 'Recent Activity',
            subtitle:
                'Results, alerts, announcements, and live status shifts appear here first.',
          ),
          const SizedBox(height: AppSpacing.md),
          if (data.recentActivity.isEmpty)
            const DashboardSectionEmpty(
              message:
                  'Recent quiz events will appear here once submissions, reminders, or status changes start flowing.',
            )
          else
            Column(
              children: [
                for (
                  var index = 0;
                  index < data.recentActivity.length;
                  index++
                ) ...[
                  _ActivityRow(item: data.recentActivity[index]),
                  if (index != data.recentActivity.length - 1)
                    const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          if (status == ViewStatus.loading && data.quizzes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            LinearProgressIndicator(
              minHeight: 3,
              backgroundColor: tokens.surfaceAlt,
            ),
          ],
        ],
      ),
    );
  }
}

class _QuizHighlights extends StatelessWidget {
  const _QuizHighlights({required this.data});

  final QuizzesWorkspaceData data;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        _SummaryPanel(
          title: 'Open Quizzes Now',
          child: data.openNow.isEmpty
              ? Text(
                  'No quiz is currently live.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
                )
              : Column(
                  children: data.openNow
                      .map(
                        (quiz) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Row(
                            children: [
                              Icon(
                                Icons.bolt_rounded,
                                color: tokens.danger,
                                size: 18,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      quiz.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: tokens.textPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      '${quiz.liveParticipants} inside now',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: tokens.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
        ),
        _SummaryPanel(
          title: 'Drafts & Today',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${data.drafts.length} draft quizzes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${data.startingToday.length} quizzes start today',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return SizedBox(
      width: 320,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: tokens.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: tokens.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: tokens.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: tokens.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_rounded, color: tokens.warning, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: tokens.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});

  final QuizWorkspaceActivity item;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    final color = switch (item.tone) {
      'danger' => tokens.danger,
      'warning' => tokens.warning,
      'success' => tokens.success,
      _ => tokens.primary,
    };
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: tokens.surfaceAlt,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: color, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            item.timeLabel,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: tokens.textSecondary),
          ),
        ],
      ),
    );
  }
}
