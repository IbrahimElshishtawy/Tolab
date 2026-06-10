import 'package:flutter/material.dart';

import 'package:tolab_fci/app/localization/app_localizations.dart';
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
                footer: '${department.sectionsCount} ${context.l10n.byValue('sections active')}',
              ),
            ),
            SizedBox(
              width: 220,
              child: DepartmentStatTile(
                label: 'Academic Staff',
                value: formatCompactNumber(department.staffCount),
                icon: Icons.groups_rounded,
                color: AppColors.secondary,
                footer: '${department.activeCoursesCount} ${context.l10n.byValue('live courses')}',
              ),
            ),
            SizedBox(
              width: 220,
              child: DepartmentStatTile(
                label: 'Subjects',
                value: formatCompactNumber(department.subjectsCount),
                icon: Icons.auto_stories_rounded,
                color: AppColors.info,
                footer: '${department.years.length} ${context.l10n.byValue('academic years')}',
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
                    '${context.l10n.byValue('Updated')} ${department.updatedAt.day}/${department.updatedAt.month}',
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
                  title: context.l10n.byValue('Students distribution'),
                  subtitle: context.l10n.byValue('Headcount split across academic years.'),
                  points: department.studentDistribution,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: DepartmentBarChartCard(
                  title: context.l10n.byValue('Subject load'),
                  subtitle: context.l10n.byValue('Current pressure index by cluster.'),
                  points: department.subjectLoad,
                  color: AppColors.warning,
                ),
              ),
            ],
          )
        else ...[
          DepartmentBarChartCard(
            title: context.l10n.byValue('Students distribution'),
            subtitle: context.l10n.byValue('Headcount split across academic years.'),
            points: department.studentDistribution,
          ),
          const SizedBox(height: AppSpacing.md),
          DepartmentBarChartCard(
            title: context.l10n.byValue('Subject load'),
            subtitle: context.l10n.byValue('Current pressure index by cluster.'),
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
                  title: context.l10n.byValue('Performance trend'),
                  subtitle:
                      context.l10n.byValue('Department success trend through the current cycle.'),
                  points: department.successTrend,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: DepartmentDonutChartCard(
                  title: context.l10n.byValue('Staff utilization'),
                  subtitle: context.l10n.byValue('Current teaching allocation by group.'),
                  points: department.staffUtilization,
                ),
              ),
            ],
          )
        else ...[
          DepartmentLineChartCard(
            title: context.l10n.byValue('Performance trend'),
            subtitle: context.l10n.byValue('Department success trend through the current cycle.'),
            points: department.successTrend,
          ),
          const SizedBox(height: AppSpacing.md),
          DepartmentDonutChartCard(
            title: context.l10n.byValue('Staff utilization'),
            subtitle: context.l10n.byValue('Current teaching allocation by group.'),
            points: department.staffUtilization,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DepartmentPanelHeader(
                title: context.l10n.byValue('Performance metrics'),
                subtitle:
                    context.l10n.byValue('High-signal KPIs for operational and academic review.'),
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
                              context.l10n.byValue(metric.label),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              context.l10n.byValue(metric.valueLabel),
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              context.l10n.byValue(metric.deltaLabel),
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
          DepartmentPanelHeader(
            title: context.l10n.byValue('Academic structure'),
            subtitle: context.l10n.byValue('Years, sections, and assigned subject plans.'),
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
                          context.l10n.byValue(years[index].yearLabel),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      Text(
                        '${years[index].sectionsCount} ${context.l10n.byValue('sections')}',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${formatCompactNumber(years[index].studentsCount)} ${context.l10n.byValue('students')}',
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
          DepartmentPanelHeader(
            title: context.l10n.byValue('Role permissions'),
            subtitle:
                context.l10n.byValue('Granular department access available to the active role.'),
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
                        context.l10n.byValue(permissions[index].title),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.byValue(permissions[index].description),
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
          DepartmentPanelHeader(
            title: context.l10n.byValue('Activity feed'),
            subtitle: context.l10n.byValue('Recent department-side operational movement.'),
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
          DepartmentPanelHeader(
            title: context.l10n.byValue('Schedule preview'),
            subtitle:
                context.l10n.byValue('Upcoming representative slots for the active department.'),
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
                        context.l10n.byValue(department.schedulePreview[index].dayLabel),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.byValue(department.schedulePreview[index].slotLabel),
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
                        context.l10n.byValue(department.schedulePreview[index].title),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${context.l10n.byValue(department.schedulePreview[index].type)} • ${context.l10n.byValue(department.schedulePreview[index].location)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.byValue(department.schedulePreview[index].staffName),
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
