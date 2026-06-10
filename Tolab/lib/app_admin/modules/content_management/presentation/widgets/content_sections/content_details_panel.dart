import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:tolab_fci/app_admin/core/animations/app_motion.dart';
import 'package:tolab_fci/app_admin/core/spacing/app_spacing.dart';
import 'package:tolab_fci/app_admin/core/widgets/app_card.dart';
import 'package:tolab_fci/app_admin/shared/widgets/premium_button.dart';
import '../../../../../state/app_state.dart';
import 'package:tolab_fci/app_admin/modules/content_management/models/content_models.dart';
import 'package:tolab_fci/app_admin/modules/content_management/state/content_actions.dart';
import 'package:tolab_fci/app_admin/modules/content_management/presentation/screens/content_management_screen.dart';
import 'package:tolab_fci/app_admin/modules/content_management/presentation/widgets/status_badge.dart';

class ContentDetailsPanel extends StatelessWidget {
  const ContentDetailsPanel({
    super.key,
    required this.vm,
    required this.onEdit,
  });

  final ContentViewModel vm;
  final Future<void> Function(
    BuildContext context,
    ContentViewModel vm,
    ContentRecord? record,
  ) onEdit;

  @override
  Widget build(BuildContext context) {
    final record = vm.activeContent;
    if (record == null) {
      return const EmptyStatePlaceholder();
    }

    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      record.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  StatusBadge(status: record.status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                record.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  ContentPill(label: record.subject.displayLabel),
                  ContentPill(label: record.section.title),
                  ContentPill(label: record.instructor.name),
                  ContentPill(label: record.visibility.label),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  PremiumButton(
                    label: 'Edit',
                    icon: Icons.edit_rounded,
                    isSecondary: true,
                    onPressed: record.permissions.canEdit
                        ? () => onEdit(context, vm, record)
                        : null,
                  ),
                  PremiumButton(
                    label: 'Publish',
                    icon: Icons.publish_rounded,
                    onPressed: record.permissions.canPublish
                        ? () => StoreProvider.of<AppState>(
                            context,
                          ).dispatch(PublishContentRequestedAction({record.id}))
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              ContentTabStrip(
                activeTab: vm.activeDetailsTab,
                onChanged: (tab) => StoreProvider.of<AppState>(
                  context,
                ).dispatch(ContentDetailsTabChangedAction(tab)),
              ),
              const SizedBox(height: AppSpacing.md),
              AnimatedSwitcher(
                duration: AppMotion.medium,
                child: switch (vm.activeDetailsTab) {
                  ContentDetailsTab.overview => ContentOverviewTab(record: record),
                  ContentDetailsTab.attachments => ContentAttachmentsTab(
                    record: record,
                  ),
                  ContentDetailsTab.submissions => ContentSubmissionsTab(
                    record: record,
                  ),
                  ContentDetailsTab.grades => ContentGradesTab(record: record),
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent activity',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              for (final item in vm.recentActivity)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: item.tone.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.icon, size: 18, color: item.tone),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class EmptyStatePlaceholder extends StatelessWidget {
  const EmptyStatePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app_rounded,
            size: 48,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Select a content item',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Preview attachments, students, submissions, and grading details here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class ContentOverviewTab extends StatelessWidget {
  const ContentOverviewTab({super.key, required this.record});

  final ContentRecord record;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('overview'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ContentStatCard(label: 'Enrolled', value: '${record.enrollmentCount}'),
            ContentStatCard(label: 'Submitted', value: '${record.submittedCount}'),
            ContentStatCard(label: 'Views', value: '${record.viewCount}'),
            ContentStatCard(label: 'Completion', value: record.completionLabel),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Students', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        for (final student in record.students.take(5))
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${student.sectionLabel} • ${student.engagementLabel}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    student.submissionStatus.label,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class ContentAttachmentsTab extends StatelessWidget {
  const ContentAttachmentsTab({super.key, required this.record});

  final ContentRecord record;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('attachments'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final attachment in record.attachments)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(child: Text(attachment.extensionLabel)),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(attachment.name),
                        const SizedBox(height: 2),
                        Text(
                          '${attachment.sizeLabel} • uploaded by ${attachment.uploadedBy}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.download_rounded, size: 18),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class ContentSubmissionsTab extends StatelessWidget {
  const ContentSubmissionsTab({super.key, required this.record});

  final ContentRecord record;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('submissions'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (record.submissions.isEmpty)
          Text(
            'No submissions yet.',
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          for (final submission in record.submissions)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(submission.studentName),
                          const SizedBox(height: 2),
                          Text(
                            '${submission.status.label} • ${submission.attempts} attempt(s)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(submission.gradeLabel),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.download_rounded, size: 18),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class ContentGradesTab extends StatelessWidget {
  const ContentGradesTab({super.key, required this.record});

  final ContentRecord record;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('grades'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final band in record.gradeBands)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(band.label)),
                    Text('${band.count} students'),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: record.enrollmentCount == 0
                      ? 0
                      : band.count / record.enrollmentCount,
                  color: band.color,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class ContentTabStrip extends StatelessWidget {
  const ContentTabStrip({
    super.key,
    required this.activeTab,
    required this.onChanged,
  });

  final ContentDetailsTab activeTab;
  final ValueChanged<ContentDetailsTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final tab in ContentDetailsTab.values)
          ChoiceChip(
            label: Text(switch (tab) {
              ContentDetailsTab.overview => 'Overview',
              ContentDetailsTab.attachments => 'Attachments',
              ContentDetailsTab.submissions => 'Submissions',
              ContentDetailsTab.grades => 'Grades',
            }),
            selected: activeTab == tab,
            onSelected: (_) => onChanged(tab),
          ),
      ],
    );
  }
}

class ContentPill extends StatelessWidget {
  const ContentPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class ContentStatCard extends StatelessWidget {
  const ContentStatCard({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
