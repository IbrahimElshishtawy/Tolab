import 'package:flutter/material.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../models/department_models.dart';
import '../charts/department_analytics_charts.dart';
import 'department_primitives.dart';

class DepartmentOverviewTab extends StatelessWidget {
  const DepartmentOverviewTab({super.key, required this.department});

  final DepartmentRecord department;

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppBreakpoints.isDesktop(context);
    return ListView(
      children: [
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            SizedBox(
              width: 220,
              child: DepartmentStatTile(
                label: 'Students',
                value: formatCompactNumber(department.studentsCount),
                icon: Icons.school_rounded,
                color: AppColors.primary,
                footer: '${department.sectionsCount} sections active',
              ),
            ),
            SizedBox(
              width: 220,
              child: DepartmentStatTile(
                label: 'Academic Staff',
                value: formatCompactNumber(department.staffCount),
                icon: Icons.groups_rounded,
                color: AppColors.secondary,
                footer: '${department.activeCoursesCount} live courses',
              ),
            ),
            SizedBox(
              width: 220,
              child: DepartmentStatTile(
                label: 'Subjects',
                value: formatCompactNumber(department.subjectsCount),
                icon: Icons.auto_stories_rounded,
                color: AppColors.info,
                footer: '${department.years.length} academic years',
              ),
            ),
            SizedBox(
              width: 220,
              child: DepartmentStatTile(
                label: 'Success Rate',
                value: formatPercent(department.successRate),
                icon: Icons.trending_up_rounded,
                color: AppColors.warning,
                footer:
                    'Updated ${department.updatedAt.day}/${department.updatedAt.month}',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DepartmentBarChartCard(
                  title: 'Students distribution',
                  subtitle: 'Headcount split across academic years.',
                  points: department.studentDistribution,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: DepartmentBarChartCard(
                  title: 'Subject load',
                  subtitle: 'Current pressure index by cluster.',
                  points: department.subjectLoad,
                  color: AppColors.warning,
                ),
              ),
            ],
          )
        else ...[
          DepartmentBarChartCard(
            title: 'Students distribution',
            subtitle: 'Headcount split across academic years.',
            points: department.studentDistribution,
          ),
          const SizedBox(height: AppSpacing.md),
          DepartmentBarChartCard(
            title: 'Subject load',
            subtitle: 'Current pressure index by cluster.',
            points: department.subjectLoad,
            color: AppColors.warning,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DepartmentLineChartCard(
                  title: 'Performance trend',
                  subtitle:
                      'Department success trend through the current cycle.',
                  points: department.successTrend,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: DepartmentDonutChartCard(
                  title: 'Staff utilization',
                  subtitle: 'Current teaching allocation by group.',
                  points: department.staffUtilization,
                ),
              ),
            ],
          )
        else ...[
          DepartmentLineChartCard(
            title: 'Performance trend',
            subtitle: 'Department success trend through the current cycle.',
            points: department.successTrend,
          ),
          const SizedBox(height: AppSpacing.md),
          DepartmentDonutChartCard(
            title: 'Staff utilization',
            subtitle: 'Current teaching allocation by group.',
            points: department.staffUtilization,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DepartmentPanelHeader(
                title: 'Performance metrics',
                subtitle:
                    'High-signal KPIs for operational and academic review.',
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  for (final metric in department.performanceMetrics)
                    SizedBox(
                      width: 260,
                      child: AppCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.03),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              metric.label,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              metric.valueLabel,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              metric.deltaLabel,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: departmentToneColor(metric.tone),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _YearsPlanCard(years: department.years)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _PermissionsCard(permissions: department.permissions),
              ),
            ],
          )
        else ...[
          _YearsPlanCard(years: department.years),
          const SizedBox(height: AppSpacing.md),
          _PermissionsCard(permissions: department.permissions),
        ],
        const SizedBox(height: AppSpacing.lg),
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _ActivityCard(department: department)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _ScheduleCard(department: department)),
            ],
          )
        else ...[
          _ActivityCard(department: department),
          const SizedBox(height: AppSpacing.md),
          _ScheduleCard(department: department),
        ],
      ],
    );
  }
}

class _YearsPlanCard extends StatelessWidget {
  const _YearsPlanCard({required this.years});

  final List<DepartmentYearPlan> years;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DepartmentPanelHeader(
            title: 'Academic structure',
            subtitle: 'Years, sections, and assigned subject plans.',
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var index = 0; index < years.length; index++) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          years[index].yearLabel,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Text(
                        '${years[index].sectionsCount} sections',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${formatCompactNumber(years[index].studentsCount)} students',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final subject in years[index].subjects)
                        Chip(
                          label: Text(
                            '${subject.code} • ${subject.creditHours}h',
                          ),
                          backgroundColor: subject.overloaded
                              ? AppColors.warningSoft
                              : null,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (index != years.length - 1)
              const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _PermissionsCard extends StatelessWidget {
  const _PermissionsCard({required this.permissions});

  final List<DepartmentPermissionRule> permissions;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DepartmentPanelHeader(
            title: 'Role permissions',
            subtitle:
                'Granular department access available to the active role.',
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var index = 0; index < permissions.length; index++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  permissions[index].granted
                      ? Icons.check_circle_rounded
                      : Icons.lock_outline_rounded,
                  color: permissions[index].granted
                      ? AppColors.secondary
                      : AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        permissions[index].title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        permissions[index].description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (index != permissions.length - 1) ...[
              const SizedBox(height: AppSpacing.md),
              Divider(color: Theme.of(context).dividerColor),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.department});

  final DepartmentRecord department;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DepartmentPanelHeader(
            title: 'Activity feed',
            subtitle: 'Recent department-side operational movement.',
          ),
          const SizedBox(height: AppSpacing.lg),
          DepartmentActivityTimeline(
            items: [
              for (final item in department.activityFeed)
                (item.title, item.subtitle, item.timestampLabel, item.tone),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.department});

  final DepartmentRecord department;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DepartmentPanelHeader(
            title: 'Schedule preview',
            subtitle:
                'Upcoming representative slots for the active department.',
          ),
          const SizedBox(height: AppSpacing.lg),
          for (
            var index = 0;
            index < department.schedulePreview.length;
            index++
          ) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 82,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        department.schedulePreview[index].dayLabel,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        department.schedulePreview[index].slotLabel,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        department.schedulePreview[index].title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${department.schedulePreview[index].type} • ${department.schedulePreview[index].location}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        department.schedulePreview[index].staffName,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (index != department.schedulePreview.length - 1) ...[
              const SizedBox(height: AppSpacing.md),
              Divider(color: Theme.of(context).dividerColor),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ],
      ),
    );
  }
}
