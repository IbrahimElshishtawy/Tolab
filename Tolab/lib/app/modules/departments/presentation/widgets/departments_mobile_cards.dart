import 'package:flutter/material.dart';

import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../models/department_models.dart';
import 'department_primitives.dart';

class DepartmentsMobileCards extends StatelessWidget {
  const DepartmentsMobileCards({
    super.key,
    required this.departments,
    required this.selectedIds,
    required this.onToggleSelection,
    required this.onOpenDepartment,
    required this.onEditDepartment,
    required this.onToggleActivation,
    required this.onArchiveDepartment,
  });

  final List<DepartmentRecord> departments;
  final Set<String> selectedIds;
  final ValueChanged<(String id, bool selected)> onToggleSelection;
  final ValueChanged<DepartmentRecord> onOpenDepartment;
  final ValueChanged<DepartmentRecord> onEditDepartment;
  final void Function(DepartmentRecord department, bool isActive)
  onToggleActivation;
  final ValueChanged<DepartmentRecord> onArchiveDepartment;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: departments.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final department = departments[index];
        final selected = selectedIds.contains(department.id);
        return AppCard(
          interactive: true,
          onTap: () => onOpenDepartment(department),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: selected,
                    onChanged: (value) =>
                        onToggleSelection((department.id, value ?? false)),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          department.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${department.code} • ${department.faculty}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  DepartmentStatusPill(label: department.statusLabel),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _MetricPill(
                    label: 'Students',
                    value: formatCompactNumber(department.studentsCount),
                  ),
                  _MetricPill(
                    label: 'Staff',
                    value: formatCompactNumber(department.staffCount),
                  ),
                  _MetricPill(
                    label: 'Subjects',
                    value: formatCompactNumber(department.subjectsCount),
                  ),
                  _MetricPill(
                    label: 'Success',
                    value: formatPercent(department.successRate),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                department.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => onOpenDepartment(department),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text('Details'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => onEditDepartment(department),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        onToggleActivation(department, !department.isActive),
                    icon: Icon(
                      department.isActive
                          ? Icons.pause_circle_outline_rounded
                          : Icons.play_circle_outline_rounded,
                      size: 18,
                    ),
                    label: Text(
                      department.isActive ? 'Deactivate' : 'Activate',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => onArchiveDepartment(department),
                    icon: const Icon(Icons.archive_outlined, size: 18),
                    label: const Text('Archive'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}
