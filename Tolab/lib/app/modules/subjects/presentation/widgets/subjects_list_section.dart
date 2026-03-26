import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../../../../core/spacing/app_spacing.dart';
import '../../models/subject_management_models.dart';
import '../design/subjects_management_tokens.dart';
import '../responsive/subjects_layout.dart';
import 'subject_feedback_state.dart';
import 'subject_primitives.dart';

class SubjectsListSection extends StatelessWidget {
  const SubjectsListSection({
    super.key,
    required this.subjects,
    required this.selectedSubject,
    required this.onSubjectSelected,
    required this.onEditSubject,
    required this.onManagePermissions,
    required this.onManagePosts,
    required this.onManageGroup,
    required this.onManageSummaries,
    required this.onViewStudents,
    required this.onGenerateAccess,
  });

  final List<SubjectRecord> subjects;
  final SubjectRecord? selectedSubject;
  final ValueChanged<SubjectRecord> onSubjectSelected;
  final ValueChanged<SubjectRecord> onEditSubject;
  final ValueChanged<SubjectRecord> onManagePermissions;
  final ValueChanged<SubjectRecord> onManagePosts;
  final ValueChanged<SubjectRecord> onManageGroup;
  final ValueChanged<SubjectRecord> onManageSummaries;
  final ValueChanged<SubjectRecord> onViewStudents;
  final ValueChanged<SubjectRecord> onGenerateAccess;

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) {
      return const SubjectFeedbackState(
        title: 'No matching subjects',
        message:
            'Try clearing filters or start by adding a subject with doctor, assistant, department, and access settings.',
      );
    }

    return SubjectSectionFrame(
      title: 'Created subjects',
      subtitle:
          'Sortable-style operational list with staff assignment, student counts, group status, content, and access controls.',
      child: SubjectsLayout.showDesktopTable(context)
          ? _SubjectsDataTable(
              subjects: subjects,
              selectedSubject: selectedSubject,
              onSubjectSelected: onSubjectSelected,
              onEditSubject: onEditSubject,
              onManagePermissions: onManagePermissions,
              onManagePosts: onManagePosts,
              onManageGroup: onManageGroup,
              onManageSummaries: onManageSummaries,
              onViewStudents: onViewStudents,
              onGenerateAccess: onGenerateAccess,
            )
          : _SubjectsCardList(
              subjects: subjects,
              selectedSubject: selectedSubject,
              onSubjectSelected: onSubjectSelected,
              onEditSubject: onEditSubject,
              onManagePermissions: onManagePermissions,
              onManagePosts: onManagePosts,
              onManageGroup: onManageGroup,
              onManageSummaries: onManageSummaries,
              onViewStudents: onViewStudents,
              onGenerateAccess: onGenerateAccess,
            ),
    );
  }
}

class _SubjectsDataTable extends StatelessWidget {
  const _SubjectsDataTable({
    required this.subjects,
    required this.selectedSubject,
    required this.onSubjectSelected,
    required this.onEditSubject,
    required this.onManagePermissions,
    required this.onManagePosts,
    required this.onManageGroup,
    required this.onManageSummaries,
    required this.onViewStudents,
    required this.onGenerateAccess,
  });

  final List<SubjectRecord> subjects;
  final SubjectRecord? selectedSubject;
  final ValueChanged<SubjectRecord> onSubjectSelected;
  final ValueChanged<SubjectRecord> onEditSubject;
  final ValueChanged<SubjectRecord> onManagePermissions;
  final ValueChanged<SubjectRecord> onManagePosts;
  final ValueChanged<SubjectRecord> onManageGroup;
  final ValueChanged<SubjectRecord> onManageSummaries;
  final ValueChanged<SubjectRecord> onViewStudents;
  final ValueChanged<SubjectRecord> onGenerateAccess;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 560,
      child: DataTable2(
        smRatio: 0.72,
        lmRatio: 1.35,
        minWidth: SubjectsManagementSpacing.tableMinWidth,
        columns: const [
          DataColumn2(label: Text('Subject'), size: ColumnSize.L),
          DataColumn2(label: Text('Department'), size: ColumnSize.M),
          DataColumn2(label: Text('Doctor / Assistant'), size: ColumnSize.L),
          DataColumn2(label: Text('Year'), size: ColumnSize.S),
          DataColumn2(label: Text('Hours'), size: ColumnSize.S),
          DataColumn2(label: Text('Students'), size: ColumnSize.M),
          DataColumn2(label: Text('Community'), size: ColumnSize.M),
          DataColumn2(label: Text('Posts / Summaries'), size: ColumnSize.M),
          DataColumn2(label: Text('Access'), size: ColumnSize.M),
          DataColumn2(label: Text('Actions'), size: ColumnSize.M),
        ],
        rows: [
          for (final subject in subjects)
            DataRow2(
              selected: selectedSubject?.id == subject.id,
              onTap: () => onSubjectSelected(subject),
              cells: [
                DataCell(_SubjectTitleCell(subject: subject)),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(subject.department),
                      const SizedBox(height: 4),
                      SubjectToneBadge(subject.status),
                    ],
                  ),
                ),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(subject.doctor.name),
                      const SizedBox(height: 4),
                      Text(
                        subject.assistant.name,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                DataCell(Text(subject.academicYear)),
                DataCell(
                  Text('${subject.creditHours} cr / ${subject.contactHours} h'),
                ),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${subject.enrolledStudents}/${subject.eligibleStudents}',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Eligible / enrolled',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SubjectToneBadge(
                        subject.group.enabled ? 'Group live' : 'No group',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subject.group.enabled
                            ? subject.group.name
                            : 'Create group',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${subject.posts.count} / ${subject.summaries.count}',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Posts / summaries',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SubjectToneBadge('Code + Link'),
                      const SizedBox(height: 4),
                      Text(
                        subject.lateRegistrationEnabled
                            ? 'Late join ready'
                            : 'Late join closed',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                DataCell(
                  _SubjectActionsMenu(
                    subject: subject,
                    onEditSubject: onEditSubject,
                    onManagePermissions: onManagePermissions,
                    onManagePosts: onManagePosts,
                    onManageGroup: onManageGroup,
                    onManageSummaries: onManageSummaries,
                    onViewStudents: onViewStudents,
                    onGenerateAccess: onGenerateAccess,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SubjectsCardList extends StatelessWidget {
  const _SubjectsCardList({
    required this.subjects,
    required this.selectedSubject,
    required this.onSubjectSelected,
    required this.onEditSubject,
    required this.onManagePermissions,
    required this.onManagePosts,
    required this.onManageGroup,
    required this.onManageSummaries,
    required this.onViewStudents,
    required this.onGenerateAccess,
  });

  final List<SubjectRecord> subjects;
  final SubjectRecord? selectedSubject;
  final ValueChanged<SubjectRecord> onSubjectSelected;
  final ValueChanged<SubjectRecord> onEditSubject;
  final ValueChanged<SubjectRecord> onManagePermissions;
  final ValueChanged<SubjectRecord> onManagePosts;
  final ValueChanged<SubjectRecord> onManageGroup;
  final ValueChanged<SubjectRecord> onManageSummaries;
  final ValueChanged<SubjectRecord> onViewStudents;
  final ValueChanged<SubjectRecord> onGenerateAccess;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final subject in subjects) ...[
          _SubjectMobileCard(
            subject: subject,
            selected: selectedSubject?.id == subject.id,
            onTap: () => onSubjectSelected(subject),
            onEditSubject: () => onEditSubject(subject),
            onManagePermissions: () => onManagePermissions(subject),
            onManagePosts: () => onManagePosts(subject),
            onManageGroup: () => onManageGroup(subject),
            onManageSummaries: () => onManageSummaries(subject),
            onViewStudents: () => onViewStudents(subject),
            onGenerateAccess: () => onGenerateAccess(subject),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _SubjectMobileCard extends StatelessWidget {
  const _SubjectMobileCard({
    required this.subject,
    required this.selected,
    required this.onTap,
    required this.onEditSubject,
    required this.onManagePermissions,
    required this.onManagePosts,
    required this.onManageGroup,
    required this.onManageSummaries,
    required this.onViewStudents,
    required this.onGenerateAccess,
  });

  final SubjectRecord subject;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEditSubject;
  final VoidCallback onManagePermissions;
  final VoidCallback onManagePosts;
  final VoidCallback onManageGroup;
  final VoidCallback onManageSummaries;
  final VoidCallback onViewStudents;
  final VoidCallback onGenerateAccess;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected
            ? SubjectsManagementPalette.accent.withValues(alpha: 0.05)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: selected
              ? SubjectsManagementPalette.accent.withValues(alpha: 0.15)
              : SubjectsManagementPalette.border(context),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _SubjectTitleCell(subject: subject)),
                  _SubjectActionsMenu(
                    subject: subject,
                    onEditSubject: (_) => onEditSubject(),
                    onManagePermissions: (_) => onManagePermissions(),
                    onManagePosts: (_) => onManagePosts(),
                    onManageGroup: (_) => onManageGroup(),
                    onManageSummaries: (_) => onManageSummaries(),
                    onViewStudents: (_) => onViewStudents(),
                    onGenerateAccess: (_) => onGenerateAccess(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  SubjectToneBadge(subject.status),
                  SubjectToneBadge(subject.department),
                  SubjectToneBadge(subject.academicYear),
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
                    label: 'Assistant',
                    value: subject.assistant.name,
                    tint: SubjectsManagementPalette.teal,
                  ),
                  SubjectInfoPill(
                    label: 'Students',
                    value:
                        '${subject.enrolledStudents}/${subject.eligibleStudents}',
                    tint: SubjectsManagementPalette.coral,
                  ),
                  SubjectInfoPill(
                    label: 'Access',
                    value: 'Code + Link',
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

class _SubjectTitleCell extends StatelessWidget {
  const _SubjectTitleCell({required this.subject});

  final SubjectRecord subject;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(subject.name, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(subject.code, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SubjectActionsMenu extends StatelessWidget {
  const _SubjectActionsMenu({
    required this.subject,
    required this.onEditSubject,
    required this.onManagePermissions,
    required this.onManagePosts,
    required this.onManageGroup,
    required this.onManageSummaries,
    required this.onViewStudents,
    required this.onGenerateAccess,
  });

  final SubjectRecord subject;
  final ValueChanged<SubjectRecord> onEditSubject;
  final ValueChanged<SubjectRecord> onManagePermissions;
  final ValueChanged<SubjectRecord> onManagePosts;
  final ValueChanged<SubjectRecord> onManageGroup;
  final ValueChanged<SubjectRecord> onManageSummaries;
  final ValueChanged<SubjectRecord> onViewStudents;
  final ValueChanged<SubjectRecord> onGenerateAccess;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Subject actions',
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEditSubject(subject);
            break;
          case 'permissions':
            onManagePermissions(subject);
            break;
          case 'posts':
            onManagePosts(subject);
            break;
          case 'group':
            onManageGroup(subject);
            break;
          case 'summaries':
            onManageSummaries(subject);
            break;
          case 'students':
            onViewStudents(subject);
            break;
          case 'access':
            onGenerateAccess(subject);
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'edit', child: Text('Edit subject')),
        PopupMenuItem(value: 'permissions', child: Text('Manage permissions')),
        PopupMenuItem(value: 'posts', child: Text('Manage posts')),
        PopupMenuItem(value: 'group', child: Text('Manage group')),
        PopupMenuItem(value: 'summaries', child: Text('Manage summaries')),
        PopupMenuItem(value: 'students', child: Text('View students')),
        PopupMenuItem(value: 'access', child: Text('Generate access')),
      ],
      child: const Icon(Icons.more_horiz_rounded),
    );
  }
}
