import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/spacing/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../models/dashboard_models.dart';
import '../state/actions/dashboard_actions.dart';

class DashboardFilterBar extends StatelessWidget {
  const DashboardFilterBar({
    super.key,
    required this.filters,
    required this.lookups,
    required this.onFilterChanged,
    required this.onReset,
    required this.isRefreshing,
  });

  final DashboardFilters filters;
  final DashboardLookups lookups;
  final void Function(DashboardFilterField field, String? value)
  onFilterChanged;
  final VoidCallback onReset;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glassColor = theme.brightness == Brightness.dark
        ? AppColors.surfaceDark.withValues(alpha: 0.78)
        : Colors.white.withValues(alpha: 0.72);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AppCard(
          backgroundColor: glassColor,
          borderColor: theme.dividerColor.withValues(alpha: 0.65),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _FilterDropdown(
                    label: 'Semester',
                    icon: Icons.calendar_month_rounded,
                    value: filters.semesterId,
                    options: lookups.semesters,
                    onChanged: (value) =>
                        onFilterChanged(DashboardFilterField.semester, value),
                  ),
                  _FilterDropdown(
                    label: 'Department',
                    icon: Icons.apartment_rounded,
                    value: filters.departmentId,
                    options: lookups.departments,
                    onChanged: (value) =>
                        onFilterChanged(DashboardFilterField.department, value),
                  ),
                  _FilterDropdown(
                    label: 'Course',
                    icon: Icons.auto_stories_rounded,
                    value: filters.courseId,
                    options: lookups.courses,
                    onChanged: (value) =>
                        onFilterChanged(DashboardFilterField.course, value),
                  ),
                  _FilterDropdown(
                    label: 'Instructor',
                    icon: Icons.person_rounded,
                    value: filters.instructorId,
                    options: lookups.instructors,
                    onChanged: (value) =>
                        onFilterChanged(DashboardFilterField.instructor, value),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: filters.isEmpty ? null : onReset,
                    icon: const Icon(Icons.restart_alt_rounded, size: 18),
                    label: const Text('Reset'),
                  ),
                ],
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                height: isRefreshing ? 3 : 0,
                margin: EdgeInsets.only(top: isRefreshing ? AppSpacing.md : 0),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.54,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.info],
                        ),
                        borderRadius: BorderRadius.circular(
                          AppConstants.pillRadius,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final String? value;
  final List<DashboardLookupOption> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<String?>(
        initialValue: options.any((option) => option.id == value)
            ? value
            : null,
        items: [
          DropdownMenuItem<String?>(value: null, child: Text('All $label')),
          ...options.map(
            (option) => DropdownMenuItem<String?>(
              value: option.id,
              child: Text(option.label, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      ),
    );
  }
}
