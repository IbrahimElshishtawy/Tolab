import 'package:flutter/material.dart';

import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../models/department_models.dart';
import 'department_primitives.dart';

class DepartmentsToolbar extends StatelessWidget {
  const DepartmentsToolbar({
    super.key,
    required this.searchController,
    required this.filters,
    required this.sort,
    required this.faculties,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onFacultyChanged,
    required this.onDensityChanged,
    required this.onSortFieldChanged,
    required this.onSortDirectionChanged,
    required this.onClearFilters,
    required this.onCreateDepartment,
    required this.canCreateDepartment,
  });

  final TextEditingController searchController;
  final DepartmentFilters filters;
  final DepartmentsSort sort;
  final List<String> faculties;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<DepartmentStatusFilter> onStatusChanged;
  final ValueChanged<String?> onFacultyChanged;
  final ValueChanged<DepartmentDensityFilter> onDensityChanged;
  final ValueChanged<DepartmentSortField> onSortFieldChanged;
  final ValueChanged<bool> onSortDirectionChanged;
  final VoidCallback onClearFilters;
  final VoidCallback onCreateDepartment;
  final bool canCreateDepartment;

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(context);
    final controls = <Widget>[
      SizedBox(
        width: isMobile ? double.infinity : 320,
        child: TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: const InputDecoration(
            hintText: 'Search name, code, head, or description',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
      ),
      SizedBox(
        width: isMobile ? double.infinity : 210,
        child: DropdownButtonFormField<String?>(
          initialValue: filters.faculty,
          onChanged: onFacultyChanged,
          decoration: const InputDecoration(labelText: 'Faculty'),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('All faculties'),
            ),
            for (final faculty in faculties)
              DropdownMenuItem<String?>(value: faculty, child: Text(faculty)),
          ],
        ),
      ),
      SizedBox(
        width: isMobile ? double.infinity : 190,
        child: DropdownButtonFormField<DepartmentDensityFilter>(
          initialValue: filters.density,
          onChanged: (value) {
            if (value != null) {
              onDensityChanged(value);
            }
          },
          decoration: const InputDecoration(labelText: 'Student density'),
          items: const [
            DropdownMenuItem(
              value: DepartmentDensityFilter.all,
              child: Text('All densities'),
            ),
            DropdownMenuItem(
              value: DepartmentDensityFilter.light,
              child: Text('Light'),
            ),
            DropdownMenuItem(
              value: DepartmentDensityFilter.balanced,
              child: Text('Balanced'),
            ),
            DropdownMenuItem(
              value: DepartmentDensityFilter.dense,
              child: Text('Dense'),
            ),
          ],
        ),
      ),
      SizedBox(
        width: isMobile ? double.infinity : 180,
        child: DropdownButtonFormField<DepartmentSortField>(
          initialValue: sort.field,
          onChanged: (value) {
            if (value != null) {
              onSortFieldChanged(value);
            }
          },
          decoration: const InputDecoration(labelText: 'Sort by'),
          items: const [
            DropdownMenuItem(
              value: DepartmentSortField.name,
              child: Text('Name'),
            ),
            DropdownMenuItem(
              value: DepartmentSortField.studentsCount,
              child: Text('Students'),
            ),
            DropdownMenuItem(
              value: DepartmentSortField.subjectsCount,
              child: Text('Subjects'),
            ),
          ],
        ),
      ),
    ];

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: controls,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DepartmentChip(
                label: 'All',
                selected: filters.status == DepartmentStatusFilter.all,
                onTap: () => onStatusChanged(DepartmentStatusFilter.all),
              ),
              DepartmentChip(
                label: 'Active',
                selected: filters.status == DepartmentStatusFilter.active,
                onTap: () => onStatusChanged(DepartmentStatusFilter.active),
              ),
              DepartmentChip(
                label: 'Inactive',
                selected: filters.status == DepartmentStatusFilter.inactive,
                onTap: () => onStatusChanged(DepartmentStatusFilter.inactive),
              ),
              const SizedBox(width: AppSpacing.sm),
              PremiumButton(
                label: sort.ascending ? 'Ascending' : 'Descending',
                icon: sort.ascending
                    ? Icons.south_rounded
                    : Icons.north_rounded,
                isSecondary: true,
                onPressed: () => onSortDirectionChanged(!sort.ascending),
              ),
              PremiumButton(
                label: 'Clear filters',
                icon: Icons.restart_alt_rounded,
                isSecondary: true,
                onPressed: onClearFilters,
              ),
              PremiumButton(
                label: 'New department',
                icon: Icons.add_rounded,
                onPressed: canCreateDepartment ? onCreateDepartment : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
