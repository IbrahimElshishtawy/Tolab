import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../models/department_models.dart';
import 'department_primitives.dart';

class DepartmentsTableCard extends StatelessWidget {
  const DepartmentsTableCard({
    super.key,
    required this.departments,
    required this.selectedIds,
    required this.areAllVisibleSelected,
    required this.currentPage,
    required this.totalPages,
    required this.perPage,
    required this.onToggleSelection,
    required this.onToggleSelectAll,
    required this.onOpenDepartment,
    required this.onEditDepartment,
    required this.onToggleActivation,
    required this.onArchiveDepartment,
    required this.onPageChanged,
    required this.onPerPageChanged,
  });

  final List<DepartmentRecord> departments;
  final Set<String> selectedIds;
  final bool areAllVisibleSelected;
  final int currentPage;
  final int totalPages;
  final int perPage;
  final ValueChanged<(String id, bool selected)> onToggleSelection;
  final ValueChanged<bool> onToggleSelectAll;
  final ValueChanged<DepartmentRecord> onOpenDepartment;
  final ValueChanged<DepartmentRecord> onEditDepartment;
  final void Function(DepartmentRecord department, bool isActive)
  onToggleActivation;
  final ValueChanged<DepartmentRecord> onArchiveDepartment;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPerPageChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DepartmentPanelHeader(
            title: 'Departments registry',
            subtitle:
                'Compact operations grid with sticky headers, role-aware actions, and instant density insight.',
            trailing: Text(
              '${departments.length} visible',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 500,
            child: DataTable2(
              columnSpacing: 18,
              horizontalMargin: 8,
              fixedTopRows: 1,
              headingRowHeight: 54,
              dataRowHeight: 72,
              showCheckboxColumn: false,
              headingCheckboxTheme: Theme.of(context).checkboxTheme,
              columns: [
                DataColumn2(
                  size: ColumnSize.S,
                  label: Checkbox(
                    value: areAllVisibleSelected,
                    onChanged: (value) => onToggleSelectAll(value ?? false),
                  ),
                ),
                const DataColumn2(label: Text('Name'), size: ColumnSize.L),
                const DataColumn2(label: Text('Code'), size: ColumnSize.S),
                const DataColumn2(label: Text('Students'), size: ColumnSize.S),
                const DataColumn2(label: Text('Staff'), size: ColumnSize.S),
                const DataColumn2(label: Text('Subjects'), size: ColumnSize.S),
                const DataColumn2(label: Text('Status'), size: ColumnSize.M),
                const DataColumn2(label: Text('Actions'), size: ColumnSize.M),
              ],
              rows: [
                for (final department in departments)
                  DataRow2(
                    color: WidgetStatePropertyAll(
                      selectedIds.contains(department.id)
                          ? AppColors.primarySoft.withValues(alpha: 0.35)
                          : null,
                    ),
                    onTap: () => onOpenDepartment(department),
                    cells: [
                      DataCell(
                        Checkbox(
                          value: selectedIds.contains(department.id),
                          onChanged: (value) => onToggleSelection((
                            department.id,
                            value ?? false,
                          )),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            Container(
                              height: 42,
                              width: 42,
                              decoration: BoxDecoration(
                                color: AppColors.info.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.apartment_rounded,
                                color: AppColors.info,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    department.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    department.faculty,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(Text(department.code)),
                      DataCell(
                        Text(formatCompactNumber(department.studentsCount)),
                      ),
                      DataCell(
                        Text(formatCompactNumber(department.staffCount)),
                      ),
                      DataCell(
                        Text(formatCompactNumber(department.subjectsCount)),
                      ),
                      DataCell(
                        DepartmentStatusPill(label: department.statusLabel),
                      ),
                      DataCell(
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'open') {
                              onOpenDepartment(department);
                              return;
                            }
                            if (value == 'edit') {
                              onEditDepartment(department);
                              return;
                            }
                            if (value == 'toggle') {
                              onToggleActivation(
                                department,
                                !department.isActive,
                              );
                              return;
                            }
                            if (value == 'archive') {
                              onArchiveDepartment(department);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'open',
                              child: Text('Open details'),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit department'),
                            ),
                            PopupMenuItem(
                              value: 'toggle',
                              child: Text(
                                department.isActive ? 'Deactivate' : 'Activate',
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'archive',
                              child: Text('Archive'),
                            ),
                          ],
                          child: const Icon(Icons.more_horiz_rounded),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                'Rows per page',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: AppSpacing.sm),
              DropdownButton<int>(
                value: perPage,
                items: const [
                  DropdownMenuItem(value: 6, child: Text('6')),
                  DropdownMenuItem(value: 9, child: Text('9')),
                  DropdownMenuItem(value: 12, child: Text('12')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onPerPageChanged(value);
                  }
                },
              ),
              const Spacer(),
              IconButton(
                onPressed: currentPage <= 1
                    ? null
                    : () => onPageChanged(currentPage - 1),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Text(
                'Page $currentPage of $totalPages',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              IconButton(
                onPressed: currentPage >= totalPages
                    ? null
                    : () => onPageChanged(currentPage + 1),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
