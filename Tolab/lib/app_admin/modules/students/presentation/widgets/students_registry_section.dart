import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../models/student_admin_models.dart';
import '../design/students_admin_tokens.dart';
import 'students_section_card.dart';
import 'students_status_badge.dart';

class StudentsRegistrySection extends StatelessWidget {
  const StudentsRegistrySection({
    super.key,
    required this.students,
    required this.selectedIds,
    required this.selectedStudentId,
    required this.sortBy,
    required this.sortAscending,
    required this.onSelectAll,
    required this.onToggleSelection,
    required this.onSort,
    required this.onOpenStudent,
  });

  final List<StudentAdminRecord> students;
  final Set<String> selectedIds;
  final String? selectedStudentId;
  final String sortBy;
  final bool sortAscending;
  final ValueChanged<bool> onSelectAll;
  final void Function(String id, bool selected) onToggleSelection;
  final ValueChanged<String> onSort;
  final ValueChanged<StudentAdminRecord> onOpenStudent;

  @override
  Widget build(BuildContext context) {
    return StudentsSectionCard(
      title: 'Student registry',
      subtitle:
          'Sortable registry with quick actions, academic signals, and responsive list behavior.',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${students.length} records',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(width: AppSpacing.sm),
          const StudentsStatusBadge('Synced'),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useCards = constraints.maxWidth < 980;
          return useCards
              ? _StudentsCardList(
                  students: students,
                  selectedIds: selectedIds,
                  selectedStudentId: selectedStudentId,
                  onToggleSelection: onToggleSelection,
                  onOpenStudent: onOpenStudent,
                )
              : _StudentsTable(
                  students: students,
                  selectedIds: selectedIds,
                  selectedStudentId: selectedStudentId,
                  sortBy: sortBy,
                  sortAscending: sortAscending,
                  onSelectAll: onSelectAll,
                  onToggleSelection: onToggleSelection,
                  onSort: onSort,
                  onOpenStudent: onOpenStudent,
                );
        },
      ),
    );
  }
}

class _StudentsTable extends StatelessWidget {
  const _StudentsTable({
    required this.students,
    required this.selectedIds,
    required this.selectedStudentId,
    required this.sortBy,
    required this.sortAscending,
    required this.onSelectAll,
    required this.onToggleSelection,
    required this.onSort,
    required this.onOpenStudent,
  });

  final List<StudentAdminRecord> students;
  final Set<String> selectedIds;
  final String? selectedStudentId;
  final String sortBy;
  final bool sortAscending;
  final ValueChanged<bool> onSelectAll;
  final void Function(String id, bool selected) onToggleSelection;
  final ValueChanged<String> onSort;
  final ValueChanged<StudentAdminRecord> onOpenStudent;

  @override
  Widget build(BuildContext context) {
    final allSelected =
        students.isNotEmpty && selectedIds.length == students.length;

    return SizedBox(
      height: 560,
      child: DataTable2(
        sortColumnIndex: _sortIndex(sortBy),
        sortAscending: sortAscending,
        showCheckboxColumn: false,
        columnSpacing: 16,
        horizontalMargin: 12,
        dataRowHeight: 84,
        headingRowHeight: 56,
        minWidth: 1120,
        columns: [
          DataColumn2(
            fixedWidth: 44,
            label: Checkbox(
              value: allSelected,
              onChanged: (value) => onSelectAll(value ?? false),
            ),
          ),
          DataColumn2(
            label: const Text('Student'),
            size: ColumnSize.L,
            onSort: (columnIndex, ascending) => onSort('student'),
          ),
          DataColumn2(
            label: const Text('Academic'),
            size: ColumnSize.L,
            onSort: (columnIndex, ascending) => onSort('academic'),
          ),
          DataColumn2(
            label: const Text('Attendance'),
            onSort: (columnIndex, ascending) => onSort('attendance'),
          ),
          DataColumn2(
            label: const Text('GPA'),
            onSort: (columnIndex, ascending) => onSort('gpa'),
          ),
          DataColumn2(
            label: const Text('Credits'),
            onSort: (columnIndex, ascending) => onSort('credits'),
          ),
          const DataColumn2(label: Text('Status')),
          const DataColumn2(label: Text('Actions'), size: ColumnSize.S),
        ],
        rows: [
          for (final student in students)
            DataRow2(
              selected: selectedStudentId == student.id,
              onTap: () => onOpenStudent(student),
              color: WidgetStatePropertyAll(
                selectedStudentId == student.id
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.transparent,
              ),
              cells: [
                DataCell(
                  Checkbox(
                    value: selectedIds.contains(student.id),
                    onChanged: (value) =>
                        onToggleSelection(student.id, value ?? false),
                  ),
                ),
                DataCell(_IdentityCell(student: student)),
                DataCell(_AcademicCell(student: student)),
                DataCell(
                  _MetricCell(
                    primary: '${student.attendanceRate.round()}%',
                    secondary:
                        '${student.lecturesAttended}/${student.totalLectures} lectures',
                  ),
                ),
                DataCell(
                  _MetricCell(
                    primary: student.cumulativeGpa.toStringAsFixed(2),
                    secondary: student.overallGrade,
                  ),
                ),
                DataCell(
                  _MetricCell(
                    primary: '${student.earnedCreditHours}',
                    secondary: '${student.remainingCreditHours} left',
                  ),
                ),
                DataCell(StudentsStatusBadge(student.status)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => onOpenStudent(student),
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_horiz_rounded, size: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  int? _sortIndex(String current) {
    return switch (current) {
      'student' => 1,
      'academic' => 2,
      'attendance' => 3,
      'gpa' => 4,
      'credits' => 5,
      _ => null,
    };
  }
}

class _StudentsCardList extends StatelessWidget {
  const _StudentsCardList({
    required this.students,
    required this.selectedIds,
    required this.selectedStudentId,
    required this.onToggleSelection,
    required this.onOpenStudent,
  });

  final List<StudentAdminRecord> students;
  final Set<String> selectedIds;
  final String? selectedStudentId;
  final void Function(String id, bool selected) onToggleSelection;
  final ValueChanged<StudentAdminRecord> onOpenStudent;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: students.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final student = students[index];
        final selected = selectedStudentId == student.id;
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 280),
          child: SlideAnimation(
            verticalOffset: 16,
            child: FadeInAnimation(
              child: InkWell(
                onTap: () => onOpenStudent(student),
                borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : StudentsAdminPalette.muted(context),
                    borderRadius: BorderRadius.circular(
                      AppConstants.mediumRadius,
                    ),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.18)
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: selectedIds.contains(student.id),
                            onChanged: (value) =>
                                onToggleSelection(student.id, value ?? false),
                          ),
                          Expanded(child: _IdentityCell(student: student)),
                          const SizedBox(width: AppSpacing.sm),
                          StudentsStatusBadge(student.status),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _InfoChip(
                            icon: Icons.apartment_rounded,
                            label: student.department,
                          ),
                          _InfoChip(
                            icon: Icons.school_rounded,
                            label:
                                '${student.academicLevel} • ${student.batch}',
                          ),
                          _InfoChip(
                            icon: Icons.grade_rounded,
                            label:
                                'GPA ${student.cumulativeGpa.toStringAsFixed(2)}',
                          ),
                          _InfoChip(
                            icon: Icons.fact_check_outlined,
                            label:
                                'Attendance ${student.attendanceRate.round()}%',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricCell(
                              primary: '${student.earnedCreditHours}',
                              secondary: 'earned credits',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _MetricCell(
                              primary: '${student.appSessionsThisWeek}',
                              secondary: 'sessions / week',
                            ),
                          ),
                          IconButton(
                            onPressed: () => onOpenStudent(student),
                            icon: const Icon(Icons.chevron_right_rounded),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _IdentityCell extends StatelessWidget {
  const _IdentityCell({required this.student});

  final StudentAdminRecord student;

  @override
  Widget build(BuildContext context) {
    final initials = student.fullName
        .split(' ')
        .take(2)
        .map((part) => part.characters.first)
        .join();
    return Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                StudentsAdminPalette.grade,
                StudentsAdminPalette.attendance,
              ],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                student.fullName,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 2),
              Text(
                '${student.id} • ${student.nationalId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AcademicCell extends StatelessWidget {
  const _AcademicCell({required this.student});

  final StudentAdminRecord student;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${student.department} • ${student.section}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 2),
        Text(
          '${student.academicLevel} • Batch ${student.batch}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({required this.primary, required this.secondary});

  final String primary;
  final String secondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(primary, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 2),
        Text(secondary, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: StudentsAdminPalette.neutral),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
