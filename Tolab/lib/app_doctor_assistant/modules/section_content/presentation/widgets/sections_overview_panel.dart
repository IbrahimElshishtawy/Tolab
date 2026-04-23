import 'package:flutter/material.dart';

import '../../../dashboard/presentation/theme/dashboard_theme_tokens.dart';
import '../../../dashboard/presentation/widgets/dashboard_section_primitives.dart';
import '../../../../core/design/app_spacing.dart';
import '../../../../core/state/async_state.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../presentation/widgets/empty_state_widget.dart';
import '../models/sections_workspace_models.dart';
import 'section_card.dart';

class SectionsOverviewPanel extends StatelessWidget {
  const SectionsOverviewPanel({
    super.key,
    required this.data,
    required this.status,
    required this.errorMessage,
    required this.onRetry,
    required this.onCreateSection,
    required this.onViewSection,
    required this.onEditSection,
    required this.onPublishSection,
    required this.onCopyLink,
    required this.onNotifyStudents,
  });

  final SectionsWorkspaceData data;
  final ViewStatus status;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onCreateSection;
  final ValueChanged<SectionWorkspaceItem> onViewSection;
  final ValueChanged<SectionWorkspaceItem> onEditSection;
  final ValueChanged<SectionWorkspaceItem> onPublishSection;
  final ValueChanged<SectionWorkspaceItem> onCopyLink;
  final ValueChanged<SectionWorkspaceItem> onNotifyStudents;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return DashboardSectionCard(
      title: 'Existing & Upcoming Sections',
      subtitle:
          'Operational visibility for section delivery, readiness issues, and fast academic follow-up.',
      trailing: DashboardToneBadge(
        label: data.healthLabel,
        tone: data.healthTone,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHighlights(data: data),
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
            title: 'Existing Sections',
            subtitle:
                'Each section card exposes delivery metadata, current status, and direct actions for the doctor or assistant.',
          ),
          const SizedBox(height: AppSpacing.md),
          if (status == ViewStatus.loading && data.sections.isEmpty)
            const LoadingStateView(lines: 4)
          else if (status == ViewStatus.failure && data.sections.isEmpty)
            ErrorStateView(
              message: errorMessage ?? 'Unable to load sections right now.',
              onRetry: onRetry,
            )
          else if (data.sections.isEmpty)
            EmptyStateWidget(
              title: 'Start by adding the first section for this subject',
              subtitle:
                  'Build the first section plan, publish it when ready, and keep delivery operations visible from one workspace.',
              actionLabel: 'Add Section',
              onAction: onCreateSection,
              icon: Icons.widgets_rounded,
            )
          else
            Column(
              children: [
                for (var index = 0; index < data.sections.length; index++) ...[
                  SectionCard(
                    section: data.sections[index],
                    onView: () => onViewSection(data.sections[index]),
                    onEdit: () => onEditSection(data.sections[index]),
                    onPublish: () => onPublishSection(data.sections[index]),
                    onCopyLink: () => onCopyLink(data.sections[index]),
                    onNotifyStudents: () =>
                        onNotifyStudents(data.sections[index]),
                  ),
                  if (index != data.sections.length - 1)
                    const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          const SizedBox(height: AppSpacing.xl),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.xl),
          const _SectionLabel(
            title: 'Needs Attention',
            subtitle:
                'Bring missing links, weak readiness, and today\'s delivery pressure to the surface.',
          ),
          const SizedBox(height: AppSpacing.md),
          if (data.needsAttention.isEmpty)
            const DashboardSectionEmpty(
              message:
                  'No urgent issues right now. Link health, notes, and today\'s section readiness all look stable.',
            )
          else
            Column(
              children: [
                for (
                  var index = 0;
                  index < data.needsAttention.length;
                  index++
                ) ...[
                  _AttentionCard(item: data.needsAttention[index]),
                  if (index != data.needsAttention.length - 1)
                    const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          const SizedBox(height: AppSpacing.xl),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.xl),
          const _SectionLabel(
            title: 'Latest Activity',
            subtitle:
                'Recent operational signals pulled from notifications, announcements, and section updates.',
          ),
          const SizedBox(height: AppSpacing.md),
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
          if (status == ViewStatus.loading && data.sections.isNotEmpty) ...[
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

class _SectionHighlights extends StatelessWidget {
  const _SectionHighlights({required this.data});

  final SectionsWorkspaceData data;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        _SummaryPanel(
          title: 'Upcoming Today',
          child: data.upcomingToday.isEmpty
              ? Text(
                  'No additional sections are scheduled for today.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
                )
              : Column(
                  children: data.upcomingToday
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                  color: item.accentColor,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
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
                                      '${item.subjectCode} - ${item.timeLabel}',
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
          title: 'Latest Sections',
          child: Column(
            children: data.latestSections
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          color: item.accentColor,
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            '${item.title} - ${item.subjectCode}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: tokens.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(growable: false),
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

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({required this.item});

  final SectionWorkspaceAlert item;

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
            height: 40,
            width: 40,
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.caption,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: tokens.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});

  final SectionWorkspaceActivity item;

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
