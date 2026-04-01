import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/animations/app_motion.dart';
import '../../../core/colors/app_colors.dart';
import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../models/enrollment_models.dart';
import 'enrollment_badge_widget.dart';
import 'enrollment_progress_widget.dart';

class EnrollmentTableWidget extends StatelessWidget {
  const EnrollmentTableWidget({
    super.key,
    required this.items,
    required this.pagination,
    required this.highlightedEnrollmentId,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChanged,
    required this.onPageChanged,
    required this.onPerPageChanged,
  });

  final List<EnrollmentRecord> items;
  final EnrollmentsPagination pagination;
  final String? highlightedEnrollmentId;
  final ValueChanged<EnrollmentRecord> onEdit;
  final ValueChanged<EnrollmentRecord> onDelete;
  final void Function(EnrollmentRecord record, EnrollmentStatus status)
  onStatusChanged;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPerPageChanged;

  @override
  Widget build(BuildContext context) {
    if (AppBreakpoints.isMobile(context)) {
      return Column(
        children: [
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _EnrollmentCard(
                item: item,
                highlighted: item.id == highlightedEnrollmentId,
                onEdit: () => onEdit(item),
                onDelete: () => onDelete(item),
                onStatusChanged: (status) => onStatusChanged(item, status),
              ),
            ),
          ),
          _PaginationFooter(
            pagination: pagination,
            onPageChanged: onPageChanged,
            onPerPageChanged: onPerPageChanged,
          ),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 520,
          child: AppCard(
            padding: EdgeInsets.zero,
            child: DataTable2(
              minWidth: 1250,
              columnSpacing: 18,
              horizontalMargin: 18,
              headingRowHeight: 52,
              dataRowHeight: 84,
              columns: const [
                DataColumn2(label: Text('Student'), size: ColumnSize.L),
                DataColumn2(label: Text('Course'), size: ColumnSize.L),
                DataColumn2(label: Text('Section')),
                DataColumn2(label: Text('Term')),
                DataColumn2(label: Text('Staff'), size: ColumnSize.L),
                DataColumn2(label: Text('Occupancy')),
                DataColumn2(label: Text('Status')),
                DataColumn2(label: Text('Actions')),
              ],
              rows: items
                  .map((item) {
                    final highlighted = item.id == highlightedEnrollmentId;
                    return DataRow2(
                      color: WidgetStatePropertyAll(
                        highlighted
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : Colors.transparent,
                      ),
                      cells: [
                        DataCell(_StudentCell(item: item)),
                        DataCell(_CourseCell(item: item)),
                        DataCell(
                          Text(
                            item.sectionName,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        DataCell(
                          Text(
                            '${item.semester}\n${item.academicYear}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        DataCell(_StaffCell(item: item)),
                        DataCell(
                          SizedBox(
                            width: 160,
                            child: EnrollmentProgressWidget(
                              value: item.occupancyRate,
                              label: item.sectionName,
                              trailing:
                                  '${item.sectionOccupancy}/${item.sectionCapacity}',
                            ),
                          ),
                        ),
                        DataCell(
                          _InlineStatusEditor(
                            value: item.status,
                            onChanged: (status) =>
                                onStatusChanged(item, status),
                          ),
                        ),
                        DataCell(
                          _ActionButtons(
                            onEdit: () => onEdit(item),
                            onDelete: () => onDelete(item),
                          ),
                        ),
                      ],
                    );
                  })
                  .toList(growable: false),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _PaginationFooter(
          pagination: pagination,
          onPageChanged: onPageChanged,
          onPerPageChanged: onPerPageChanged,
        ),
      ],
    );
  }
}

class _EnrollmentCard extends StatelessWidget {
  const _EnrollmentCard({
    required this.item,
    required this.highlighted,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChanged,
  });

  final EnrollmentRecord item;
  final bool highlighted;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<EnrollmentStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.medium,
      curve: AppMotion.emphasized,
      child: AppCard(
        interactive: true,
        borderColor: highlighted
            ? AppColors.primary.withValues(alpha: 0.26)
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _StudentCell(item: item)),
                const SizedBox(width: AppSpacing.sm),
                EnrollmentBadgeWidget(item.status),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _CourseCell(item: item),
            const SizedBox(height: AppSpacing.md),
            _StaffCell(item: item),
            const SizedBox(height: AppSpacing.md),
            EnrollmentProgressWidget(
              value: item.occupancyRate,
              label: '${item.sectionName} • ${item.semester}',
              trailing: '${item.sectionOccupancy}/${item.sectionCapacity}',
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _InlineStatusEditor(
                    value: item.status,
                    onChanged: onStatusChanged,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _ActionButtons(onEdit: onEdit, onDelete: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentCell extends StatelessWidget {
  const _StudentCell({required this.item});

  final EnrollmentRecord item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(item.studentName, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${item.studentId} • ${item.studentEmail}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _CourseCell extends StatelessWidget {
  const _CourseCell({required this.item});

  final EnrollmentRecord item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(item.courseName, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${item.courseCode} • ${item.departmentName}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _StaffCell extends StatelessWidget {
  const _StaffCell({required this.item});

  final EnrollmentRecord item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(item.doctorName, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'TA: ${item.assistantName}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _InlineStatusEditor extends StatelessWidget {
  const _InlineStatusEditor({required this.value, required this.onChanged});

  final EnrollmentStatus value;
  final ValueChanged<EnrollmentStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: value.color.withValues(alpha: 0.08),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<EnrollmentStatus>(
          value: value,
          isDense: true,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          selectedItemBuilder: (context) => EnrollmentStatus.values
              .map(
                (status) => Align(
                  alignment: Alignment.centerLeft,
                  child: EnrollmentBadgeWidget(status),
                ),
              )
              .toList(growable: false),
          items: EnrollmentStatus.values
              .map(
                (status) => DropdownMenuItem<EnrollmentStatus>(
                  value: status,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: EnrollmentBadgeWidget(status),
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: (status) {
            if (status != null) onChanged(status);
          },
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'Edit',
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline_rounded),
          tooltip: 'Delete',
        ),
      ],
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.pagination,
    required this.onPageChanged,
    required this.onPerPageChanged,
  });

  final EnrollmentsPagination pagination;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPerPageChanged;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM');
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Page ${pagination.page} of ${pagination.totalPages} • ${pagination.totalItems} results • Updated ${formatter.format(DateTime.now())}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          DropdownButton<int>(
            value: pagination.perPage,
            underline: const SizedBox.shrink(),
            items: const [10, 20, 50]
                .map(
                  (value) => DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value / page'),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) onPerPageChanged(value);
            },
          ),
          const SizedBox(width: AppSpacing.md),
          IconButton(
            onPressed: pagination.page <= 1
                ? null
                : () => onPageChanged(pagination.page - 1),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          IconButton(
            onPressed: pagination.page >= pagination.totalPages
                ? null
                : () => onPageChanged(pagination.page + 1),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}
