import 'package:flutter/material.dart';

import '../../../../core/spacing/app_spacing.dart';
import '../../models/subject_management_models.dart';
import '../design/subjects_management_tokens.dart';
import 'subject_primitives.dart';

enum SubjectsGroupBy { department, academicYear, status, doctor }

extension SubjectsGroupByLabel on SubjectsGroupBy {
  String get label => switch (this) {
    SubjectsGroupBy.department => 'Department',
    SubjectsGroupBy.academicYear => 'Academic Year',
    SubjectsGroupBy.status => 'Status',
    SubjectsGroupBy.doctor => 'Doctor',
  };
}

class GroupedSubjectsSection extends StatelessWidget {
  const GroupedSubjectsSection({
    super.key,
    required this.subjects,
    required this.groupBy,
    required this.onGroupByChanged,
    required this.onSubjectSelected,
  });

  final List<SubjectRecord> subjects;
  final SubjectsGroupBy groupBy;
  final ValueChanged<SubjectsGroupBy> onGroupByChanged;
  final ValueChanged<SubjectRecord> onSubjectSelected;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<SubjectRecord>>{};
    for (final subject in subjects) {
      final key = switch (groupBy) {
        SubjectsGroupBy.department => subject.department,
        SubjectsGroupBy.academicYear => subject.academicYear,
        SubjectsGroupBy.status => subject.status,
        SubjectsGroupBy.doctor => subject.doctor.name,
      };
      groups.putIfAbsent(key, () => []).add(subject);
    }

    final entries = groups.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return SubjectSectionFrame(
      title: 'Grouped organization view',
      subtitle:
          'Scan dense subject sets faster by grouping them into premium visual sections.',
      trailing: SubjectsSegmentedControl<SubjectsGroupBy>(
        currentValue: groupBy,
        values: SubjectsGroupBy.values,
        labelBuilder: (value) => value.label,
        onChanged: onGroupByChanged,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in entries) ...[
            _GroupBucket(
              title: entry.key,
              subjects: entry.value,
              onSubjectSelected: onSubjectSelected,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class _GroupBucket extends StatelessWidget {
  const _GroupBucket({
    required this.title,
    required this.subjects,
    required this.onSubjectSelected,
  });

  final String title;
  final List<SubjectRecord> subjects;
  final ValueChanged<SubjectRecord> onSubjectSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(width: AppSpacing.sm),
            SubjectToneBadge('${subjects.length} subjects'),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth < 700
                ? constraints.maxWidth
                : (constraints.maxWidth - AppSpacing.md) / 2;
            return Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                for (final subject in subjects)
                  SizedBox(
                    width: cardWidth,
                    child: _GroupedSubjectCard(
                      subject: subject,
                      onTap: () => onSubjectSelected(subject),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _GroupedSubjectCard extends StatelessWidget {
  const _GroupedSubjectCard({required this.subject, required this.onTap});

  final SubjectRecord subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: SubjectsManagementPalette.muted(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: SubjectsManagementPalette.border(context)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subject.code,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  SubjectToneBadge(subject.status),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  SubjectInfoPill(
                    label: 'Doctor',
                    value: subject.doctor.name,
                    tint: SubjectsManagementPalette.accent,
                  ),
                  SubjectInfoPill(
                    label: 'Students',
                    value:
                        '${subject.enrolledStudents}/${subject.eligibleStudents}',
                    tint: SubjectsManagementPalette.teal,
                  ),
                  SubjectInfoPill(
                    label: 'Group',
                    value: subject.group.enabled
                        ? subject.group.name
                        : 'Not created',
                    tint: SubjectsManagementPalette.violet,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
