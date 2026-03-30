import 'package:flutter/material.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../state/departments_selectors.dart';
import 'department_primitives.dart';

class DepartmentsSummaryStrip extends StatelessWidget {
  const DepartmentsSummaryStrip({super.key, required this.metrics});

  final DepartmentsSummaryMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        SizedBox(
          width: 240,
          child: DepartmentStatTile(
            label: 'Departments',
            value: metrics.departmentsCount.toString(),
            icon: Icons.apartment_rounded,
            color: AppColors.primary,
            footer: '${metrics.activeDepartmentsCount} active now',
          ),
        ),
        SizedBox(
          width: 240,
          child: DepartmentStatTile(
            label: 'Students',
            value: formatCompactNumber(metrics.studentsCount),
            icon: Icons.school_rounded,
            color: AppColors.info,
            footer: 'Across all filtered faculties',
          ),
        ),
        SizedBox(
          width: 240,
          child: DepartmentStatTile(
            label: 'Academic Staff',
            value: formatCompactNumber(metrics.staffCount),
            icon: Icons.groups_rounded,
            color: AppColors.secondary,
            footer: '${metrics.activeCoursesCount} active course offerings',
          ),
        ),
        SizedBox(
          width: 240,
          child: DepartmentStatTile(
            label: 'Average Success',
            value: formatPercent(metrics.averageSuccessRate),
            icon: Icons.trending_up_rounded,
            color: AppColors.warning,
            footer: 'Module-wide completion performance',
          ),
        ),
      ],
    );
  }
}
