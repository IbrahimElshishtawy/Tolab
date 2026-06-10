import 'package:flutter/material.dart';

import '../../../../../app/localization/app_localizations.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../models/section_management_models.dart';
import 'section_management_primitives.dart';

class SectionSubjectsTab extends StatelessWidget {
  const SectionSubjectsTab({
    super.key,
    required this.subjects,
    required this.onAssignSubject,
  });

  final List<SectionSubjectRecord> subjects;
  final VoidCallback onAssignSubject;

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SectionPanelHeader(
            title: context.l10n.byValue('Assigned subjects'),
            subtitle:
                context.l10n.byValue('Subject ownership, lecture counts, and instructor alignment for this section.'),
            trailing: PremiumButton(
              label: context.l10n.byValue('Assign subject'),
              icon: Icons.playlist_add_rounded,
              onPressed: onAssignSubject,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (isMobile)
          Column(
            children: [
              for (final subject in subjects) ...[
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${subject.code} • ${context.l10n.byValue(subject.title)}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          StatusBadge(subject.status),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _MetricLine(
                        label: context.l10n.byValue('Instructor'),
                        value: context.l10n.byValue(subject.instructorName),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _MetricLine(
                        label: context.l10n.byValue('Lectures'),
                        value: subject.lecturesCount.toString(),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _MetricLine(
                        label: context.l10n.byValue('Delivery'),
                        value: context.l10n.byValue(subject.deliveryLabel),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SectionCapacityBar(
                        value: subject.completionRate,
                        label:
                            '${(subject.completionRate * 100).round()}% ${context.l10n.byValue('delivery completion')}',
                      ),
                    ],
                  ),
                ),
                if (subject != subjects.last)
                  const SizedBox(height: AppSpacing.md),
              ],
            ],
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _TableHeaderRow(
                  columns: [
                    _TableColumn(label: context.l10n.byValue('Subject'), flex: 3),
                    _TableColumn(label: context.l10n.byValue('Lectures'), flex: 1),
                    _TableColumn(label: context.l10n.byValue('Instructor'), flex: 2),
                    _TableColumn(label: context.l10n.byValue('Delivery'), flex: 2),
                    _TableColumn(label: context.l10n.byValue('Status'), flex: 1),
                    _TableColumn(label: context.l10n.byValue('Progress'), flex: 2),
                  ],
                ),
                for (final subject in subjects)
                  _SubjectTableRow(subject: subject),
              ],
            ),
          ),
      ],
    );
  }
}

class _TableColumn {
  const _TableColumn({required this.label, required this.flex});

  final String label;
  final int flex;
}

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow({required this.columns});

  final List<_TableColumn> columns;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.cardRadius),
        ),
      ),
      child: Row(
        children: [
          for (final column in columns)
            Expanded(
              flex: column.flex,
              child: Text(
                column.label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
        ],
      ),
    );
  }
}

class _SubjectTableRow extends StatelessWidget {
  const _SubjectTableRow({required this.subject});

  final SectionSubjectRecord subject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${subject.code} • ${context.l10n.byValue(subject.title)}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.byValue(subject.deliveryLabel),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Expanded(flex: 1, child: Text(subject.lecturesCount.toString())),
          Expanded(flex: 2, child: Text(context.l10n.byValue(subject.instructorName))),
          Expanded(flex: 2, child: Text(context.l10n.byValue(subject.deliveryLabel))),
          Expanded(flex: 1, child: StatusBadge(subject.status)),
          Expanded(
            flex: 2,
            child: SectionCapacityBar(
              value: subject.completionRate,
              label: '${(subject.completionRate * 100).round()}%',
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricLine extends StatelessWidget {
  const _MetricLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Text(value, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}
