import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../../app/localization/app_localizations.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/animations/app_motion.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../models/section_management_models.dart';
import '../design/section_management_tokens.dart';
import 'section_management_primitives.dart';

class SectionStudentsTab extends StatefulWidget {
  const SectionStudentsTab({
    super.key,
    required this.selectedRecord,
    required this.siblingRecords,
    required this.onMoveStudents,
    required this.onRemoveStudents,
    required this.onAddStudent,
    required this.showSnack,
  });

  final SectionManagementRecord selectedRecord;
  final List<SectionManagementRecord> siblingRecords;
  final void Function(Set<String> studentIds, String targetSectionId) onMoveStudents;
  final void Function(Set<String> studentIds) onRemoveStudents;
  final VoidCallback onAddStudent;
  final void Function(String message) showSnack;

  @override
  State<SectionStudentsTab> createState() => _SectionStudentsTabState();
}

class _SectionStudentsTabState extends State<SectionStudentsTab> {
  String _studentQuery = '';
  String _studentStatusFilter = 'All';
  String _studentYearFilter = 'All';
  String _studentDepartmentFilter = 'All';
  int _studentPage = 0;
  final Set<String> _selectedStudentIds = <String>{};

  @override
  void didUpdateWidget(covariant SectionStudentsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedRecord.id != widget.selectedRecord.id) {
      _selectedStudentIds.clear();
      _studentPage = 0;
      _studentQuery = '';
      _studentStatusFilter = 'All';
      _studentYearFilter = 'All';
      _studentDepartmentFilter = 'All';
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.selectedRecord;
    final deviceType = AppBreakpoints.resolve(context);
    final filteredStudents = _filteredStudents();
    final pageSize = deviceType == DeviceScreenType.mobile ? 4 : 6;
    final totalPages = math.max(1, (filteredStudents.length / pageSize).ceil());
    final currentPage = _studentPage.clamp(0, totalPages - 1);
    final visibleStudents = filteredStudents
        .skip(currentPage * pageSize)
        .take(pageSize)
        .toList();
    final transferTargets = widget.siblingRecords;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionPanelHeader(
                title: context.l10n.byValue('Students'),
                subtitle:
                    context.l10n.byValue('Search, filter, bulk manage, and drag students across sections without losing visibility.'),
                trailing: PremiumButton(
                  label: 'Add student',
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: widget.onAddStudent,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildStudentFilters(context),
              const SizedBox(height: AppSpacing.md),
              _buildBulkActionsBar(filteredStudents.length),
              const SizedBox(height: AppSpacing.lg),
              _buildDragDropBoard(visibleStudents, transferTargets),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (deviceType == DeviceScreenType.mobile)
          _buildStudentCards(visibleStudents)
        else
          _buildStudentsTable(visibleStudents),
        const SizedBox(height: AppSpacing.md),
        _PaginationBar(
          currentPage: currentPage,
          totalPages: totalPages,
          onPrevious: currentPage == 0
              ? null
              : () => setState(() => _studentPage = currentPage - 1),
          onNext: currentPage == totalPages - 1
              ? null
              : () => setState(() => _studentPage = currentPage + 1),
          label:
              '${context.l10n.byValue('Showing')} ${visibleStudents.length} ${context.l10n.byValue('of')} ${filteredStudents.length} ${context.l10n.byValue('students')} ${context.l10n.byValue('in')} ${record.code}',
        ),
      ],
    );
  }

  Widget _buildStudentFilters(BuildContext context) {
    final yearOptions = [
      'All',
      ...widget.selectedRecord.students.map((student) => student.yearLabel).toSet(),
    ];
    final departmentOptions = [
      'All',
      ...widget.selectedRecord.students.map((student) => student.department).toSet(),
    ];

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        SizedBox(
          width: 280,
          child: TextField(
            onChanged: (value) => setState(() {
              _studentQuery = value;
              _studentPage = 0;
            }),
            decoration: InputDecoration(
              hintText: context.l10n.byValue('Search by name, email, or student ID'),
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
        ),
        SizedBox(
          width: 170,
          child: _FilterDropdown(
            label: context.l10n.byValue('Status'),
            value: _studentStatusFilter,
            items: const ['All', 'Active', 'Inactive'],
            onChanged: (value) => setState(() {
              _studentStatusFilter = value;
              _studentPage = 0;
            }),
          ),
        ),
        SizedBox(
          width: 170,
          child: _FilterDropdown(
            label: context.l10n.byValue('Year'),
            value: _studentYearFilter,
            items: yearOptions,
            onChanged: (value) => setState(() {
              _studentYearFilter = value;
              _studentPage = 0;
            }),
          ),
        ),
        SizedBox(
          width: 190,
          child: _FilterDropdown(
            label: context.l10n.byValue('Department'),
            value: _studentDepartmentFilter,
            items: departmentOptions,
            onChanged: (value) => setState(() {
              _studentDepartmentFilter = value;
              _studentPage = 0;
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildBulkActionsBar(int filteredCount) {
    final selectedCount = _selectedStudentIds.length;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.md,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '$selectedCount ${context.l10n.byValue('selected')}  •  $filteredCount ${context.l10n.byValue('matching current filters')}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          PremiumButton(
            label: 'Remove students',
            icon: Icons.person_remove_alt_1_rounded,
            isSecondary: true,
            onPressed: selectedCount == 0 ? null : () {
              widget.onRemoveStudents(_selectedStudentIds);
              setState(() => _selectedStudentIds.clear());
            },
          ),
          PremiumButton(
            label: 'Move students',
            icon: Icons.swap_horiz_rounded,
            onPressed: selectedCount == 0 ? null : _showBulkMoveSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildDragDropBoard(
    List<SectionStudentRecord> visibleStudents,
    List<SectionManagementRecord> transferTargets,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.byValue('Drag and drop assignment'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          context.l10n.byValue('Drag roster cards into another cohort to simulate fast transfer decisions.'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final student in visibleStudents.take(4))
              LongPressDraggable<SectionStudentRecord>(
                data: student,
                feedback: Material(
                  color: Colors.transparent,
                  child: _StudentDragChip(student: student, elevated: true),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.35,
                  child: _StudentDragChip(student: student),
                ),
                child: _StudentDragChip(student: student),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            for (final target in transferTargets)
              SizedBox(
                width: 220,
                child: DragTarget<SectionStudentRecord>(
                  onAcceptWithDetails: (details) =>
                      widget.onMoveStudents({details.data.id}, target.id),
                  builder: (context, candidates, rejected) {
                    final isHovering = candidates.isNotEmpty;
                    return AnimatedContainer(
                      duration: AppMotion.fast,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isHovering
                            ? AppColors.secondary.withValues(alpha: 0.08)
                            : SectionManagementPalette.surface(context),
                        borderRadius: BorderRadius.circular(
                          AppConstants.mediumRadius,
                        ),
                        border: Border.all(
                          color: isHovering
                              ? AppColors.secondary
                              : Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  target.code,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              StatusBadge(target.status),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${context.l10n.byValue(target.department)} • ${context.l10n.byValue(target.yearLabel)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SectionCapacityBar(
                            value: target.capacityUsage,
                            label:
                                '${target.studentsCount}/${target.capacity} ${context.l10n.byValue('seats')}',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStudentsTable(List<SectionStudentRecord> students) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _TableHeaderRow(
            columns: [
              _TableColumn(label: context.l10n.byValue('Student'), flex: 3),
              _TableColumn(label: context.l10n.byValue('Status'), flex: 2),
              _TableColumn(label: context.l10n.byValue('Year'), flex: 1),
              _TableColumn(label: context.l10n.byValue('Department'), flex: 2),
              _TableColumn(label: context.l10n.byValue('GPA'), flex: 1),
              _TableColumn(label: context.l10n.byValue('Attendance'), flex: 2),
              _TableColumn(label: context.l10n.byValue('Selection'), flex: 1),
            ],
          ),
          for (final student in students)
            _StudentTableRow(
              student: student,
              selected: _selectedStudentIds.contains(student.id),
              onChanged: (checked) =>
                  _toggleStudentSelection(student.id, checked ?? false),
            ),
        ],
      ),
    );
  }

  Widget _buildStudentCards(List<SectionStudentRecord> students) {
    return Column(
      children: [
        for (final student in students) ...[
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SectionAvatar(
                      label: student.initials,
                      backgroundColor: student.isAtRisk
                          ? AppColors.warning
                          : AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            student.email,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: _selectedStudentIds.contains(student.id),
                      onChanged: (checked) =>
                          _toggleStudentSelection(student.id, checked ?? false),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    StatusBadge(student.status),
                    _InfoPill(
                      icon: Icons.school_outlined,
                      label: student.yearLabel,
                    ),
                    _InfoPill(
                      icon: Icons.apartment_rounded,
                      label: student.department,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _MetricLine(
                  label: context.l10n.byValue('GPA'),
                  value: student.gpa.toStringAsFixed(2),
                ),
                const SizedBox(height: AppSpacing.xs),
                _MetricLine(
                  label: context.l10n.byValue('Attendance'),
                  value: formatPercentValue(student.attendanceRate),
                ),
                const SizedBox(height: AppSpacing.xs),
                _MetricLine(
                  label: context.l10n.byValue('Last activity'),
                  value: context.l10n.byValue(student.lastActivityLabel),
                ),
              ],
            ),
          ),
          if (student != students.last) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }

  List<SectionStudentRecord> _filteredStudents() {
    final query = _studentQuery.trim().toLowerCase();
    return widget.selectedRecord.students.where((student) {
      final matchesQuery =
          query.isEmpty ||
          student.name.toLowerCase().contains(query) ||
          student.email.toLowerCase().contains(query) ||
          student.id.toLowerCase().contains(query);
      final matchesStatus =
          _studentStatusFilter == 'All' ||
          student.status == _studentStatusFilter;
      final matchesYear =
          _studentYearFilter == 'All' ||
          student.yearLabel == _studentYearFilter;
      final matchesDepartment =
          _studentDepartmentFilter == 'All' ||
          student.department == _studentDepartmentFilter;
      return matchesQuery && matchesStatus && matchesYear && matchesDepartment;
    }).toList();
  }

  void _toggleStudentSelection(String studentId, bool selected) {
    setState(() {
      if (selected) {
        _selectedStudentIds.add(studentId);
      } else {
        _selectedStudentIds.remove(studentId);
      }
    });
  }

  Future<void> _showBulkMoveSheet() async {
    final target = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.byValue('Move selected students'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.byValue('Choose the target section for the current selection.'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              for (final target in widget.siblingRecords)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(target.code),
                  subtitle: Text('${context.l10n.byValue(target.department)} • ${context.l10n.byValue(target.yearLabel)}'),
                  trailing: Text(
                    '${target.studentsCount}/${target.capacity}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  onTap: () => Navigator.of(context).pop(target.id),
                ),
            ],
          ),
        );
      },
    );

    if (!mounted || target == null) return;
    widget.onMoveStudents(_selectedStudentIds, target);
    setState(() => _selectedStudentIds.clear());
  }
}

class _StudentDragChip extends StatelessWidget {
  const _StudentDragChip({required this.student, this.elevated = false});

  final SectionStudentRecord student;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: SectionManagementPalette.surface(context),
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: SectionManagementPalette.softShadow(
                    context,
                  ).withValues(alpha: 0.16),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.drag_indicator_rounded,
            size: 18,
            color: SectionManagementPalette.subtleText(context),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(student.name, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      selectedItemBuilder: (context) => [
        for (final item in items)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(context.l10n.byValue(item), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
      ],
      items: [
        for (final item in items)
          DropdownMenuItem(
            value: item,
            child: Text(context.l10n.byValue(item), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (selected) {
        if (selected != null) onChanged(selected);
      },
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int totalPages;
  final String label;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Text(
            '${currentPage + 1} / $totalPages',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
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

class _StudentTableRow extends StatelessWidget {
  const _StudentTableRow({
    required this.student,
    required this.selected,
    required this.onChanged,
  });

  final SectionStudentRecord student;
  final bool selected;
  final ValueChanged<bool?> onChanged;

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
            child: Row(
              children: [
                SectionAvatar(
                  label: student.initials,
                  backgroundColor: student.isAtRisk
                      ? AppColors.warning
                      : AppColors.primary,
                  radius: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        student.email,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: StatusBadge(student.status)),
          Expanded(flex: 1, child: Text(context.l10n.byValue(student.yearLabel))),
          Expanded(flex: 2, child: Text(context.l10n.byValue(student.department))),
          Expanded(flex: 1, child: Text(student.gpa.toStringAsFixed(2))),
          Expanded(
            flex: 2,
            child: Text(formatPercentValue(student.attendanceRate)),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Checkbox(value: selected, onChanged: onChanged),
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

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: SectionManagementPalette.frostedSurface(
          context,
          lightAlpha: 0.72,
        ),
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: SectionManagementPalette.subtleText(context),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
