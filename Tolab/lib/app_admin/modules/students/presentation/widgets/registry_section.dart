import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import 'package:tolab_fci/app/localization/app_localizations.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../models/student_management_models.dart';
import '../../state/students_state.dart';
import '../../widgets/student_module_primitives.dart';
import 'student_profile_panel.dart';

class RegistrySection extends StatelessWidget {
  const RegistrySection({
    super.key,
    required this.state,
    required this.students,
    required this.selectedStudent,
    required this.onSelectStudent,
    required this.onToggleSelection,
    required this.onSelectAll,
    required this.onClearSelection,
    required this.onSort,
    required this.onApproveSelected,
    required this.onRejectSelected,
    required this.onAssignCourse,
    required this.onEditStudent,
    required this.onUploadDocuments,
    required this.onExportTranscript,
    required this.onDownloadBundle,
    required this.showSidePanel,
    required this.onApproveDocument,
    required this.onRejectDocument,
  });

  final StudentsState state;
  final List<StudentProfile> students;
  final StudentProfile? selectedStudent;
  final ValueChanged<String> onSelectStudent;
  final ValueChanged<String> onToggleSelection;
  final VoidCallback onSelectAll;
  final VoidCallback onClearSelection;
  final ValueChanged<String> onSort;
  final VoidCallback onApproveSelected;
  final VoidCallback onRejectSelected;
  final VoidCallback onAssignCourse;
  final VoidCallback onEditStudent;
  final VoidCallback onUploadDocuments;
  final VoidCallback onExportTranscript;
  final VoidCallback onDownloadBundle;
  final bool showSidePanel;
  final ValueChanged<StudentDocumentRecord> onApproveDocument;
  final ValueChanged<StudentDocumentRecord> onRejectDocument;

  @override
  Widget build(BuildContext context) {
    final resolvedSelectedStudent = selectedStudent;
    final table = StudentSectionCard(
      title: context.l10n.byValue('Student registry'),
      subtitle: context.l10n.byValue(
          'Sticky-header student registry with live search results, bulk actions, and deep profile drilldown.'),
      trailing: state.selectedStudentIds.isEmpty
          ? StudentStatusPill(
              label: '${students.length} ${context.l10n.byValue('results')}',
              color: AppColors.info,
            )
          : Wrap(
              spacing: AppSpacing.sm,
              children: [
                FilledButton.tonal(
                  onPressed: onApproveSelected,
                  child: Text(context.l10n.byValue('Approve')),
                ),
                FilledButton.tonal(
                  onPressed: onRejectSelected,
                  child: Text(context.l10n.byValue('Reject')),
                ),
                OutlinedButton(
                  onPressed: onAssignCourse,
                  child: Text(context.l10n.byValue('Assign course')),
                ),
                TextButton(
                  onPressed: onClearSelection,
                  child: Text('${state.selectedStudentIds.length} ${context.l10n.byValue('selected')}'),
                ),
              ],
            ),
      child: SizedBox(
        height: 520,
        child: DataTable2(
          fixedTopRows: 1,
          minWidth: 1120,
          sortAscending: state.sortAscending,
          sortColumnIndex: switch (state.sortColumn) {
            'name' => 1,
            'department' => 2,
            'attendance' => 3,
            'gpa' => 4,
            _ => 5,
          },
          columns: [
            DataColumn2(
              fixedWidth: 40,
              label: IconButton(
                onPressed: onSelectAll,
                icon: const Icon(Icons.done_all_rounded),
              ),
            ),
            DataColumn2(
              label: Text(context.l10n.byValue('Student')),
              size: ColumnSize.L,
              onSort: (_, _) => onSort('name'),
            ),
            DataColumn2(
              label: Text(context.l10n.byValue('Department')),
              onSort: (_, _) => onSort('department'),
            ),
            DataColumn2(
              label: Text(context.l10n.byValue('Attendance')),
              onSort: (_, _) => onSort('attendance'),
            ),
            DataColumn2(
              label: Text(context.l10n.byValue('GPA')),
              onSort: (_, _) => onSort('gpa'),
            ),
            DataColumn2(
              label: Text(context.l10n.byValue('Status')),
              onSort: (_, _) => onSort('status'),
            ),
            DataColumn2(label: Text(context.l10n.byValue('Actions')), size: ColumnSize.S),
          ],
          rows: [
            for (final student in students)
              DataRow2(
                selected: resolvedSelectedStudent?.id == student.id,
                onTap: () => onSelectStudent(student.id),
                cells: [
                  DataCell(
                    Checkbox(
                      value: state.selectedStudentIds.contains(student.id),
                      onChanged: (_) => onToggleSelection(student.id),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        StudentAvatar(name: student.fullName),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(student.fullName),
                              Text(
                                '${student.studentNumber} • ${student.contact.email}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(Text('${context.l10n.byValue(student.department)} • Y${student.year}')),
                  DataCell(
                    Text('${student.attendanceRate.toStringAsFixed(0)}%'),
                  ),
                  DataCell(Text(student.gpa.toStringAsFixed(2))),
                  DataCell(
                    StudentStatusPill(
                      label: context.l10n.byValue(student.enrollmentStatus.label),
                      color: student.isAtRisk
                          ? AppColors.danger
                          : AppColors.success,
                    ),
                  ),
                  DataCell(
                    IconButton(
                      onPressed: () => onSelectStudent(student.id),
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );

    if (!showSidePanel || resolvedSelectedStudent == null) {
      return Column(
        children: [
          table,
          if (resolvedSelectedStudent != null) ...[
            const SizedBox(height: AppSpacing.lg),
            StudentProfilePanel(
              student: resolvedSelectedStudent,
              onEditStudent: onEditStudent,
              onUploadDocuments: onUploadDocuments,
              onExportTranscript: onExportTranscript,
              onDownloadBundle: onDownloadBundle,
              onApproveDocument: onApproveDocument,
              onRejectDocument: onRejectDocument,
            ),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: table),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 4,
          child: StudentProfilePanel(
            student: resolvedSelectedStudent,
            onEditStudent: onEditStudent,
            onUploadDocuments: onUploadDocuments,
            onExportTranscript: onExportTranscript,
            onDownloadBundle: onDownloadBundle,
            onApproveDocument: onApproveDocument,
            onRejectDocument: onRejectDocument,
            height: 520,
          ),
        ),
      ],
    );
  }
}
