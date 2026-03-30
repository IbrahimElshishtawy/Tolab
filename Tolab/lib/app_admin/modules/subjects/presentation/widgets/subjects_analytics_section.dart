import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../models/subject_management_models.dart';
import '../charts/subjects_analytics_charts.dart';
import '../design/subjects_management_tokens.dart';
import 'subject_primitives.dart';

class SubjectsAnalyticsSection extends StatelessWidget {
  const SubjectsAnalyticsSection({super.key, required this.subjects});

  final List<SubjectRecord> subjects;

  @override
  Widget build(BuildContext context) {
    final departmentCounts = <String, int>{};
    final yearCounts = <String, int>{};
    final doctors = <String>{};
    final assistants = <String>{};
    var totalEnrollment = 0;
    var groups = 0;
    var posts = 0;
    var summaries = 0;
    final lineAccumulator = List<double>.filled(7, 0);

    for (final subject in subjects) {
      departmentCounts.update(
        subject.department,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
      yearCounts.update(
        subject.academicYear,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
      doctors.add(subject.doctor.name);
      assistants.add(subject.assistant.name);
      totalEnrollment += subject.enrolledStudents;
      groups += subject.group.enabled ? 1 : 0;
      posts += subject.posts.count;
      summaries += subject.summaries.count;
      for (
        var i = 0;
        i < subject.activity.length && i < lineAccumulator.length;
        i++
      ) {
        lineAccumulator[i] += subject.activity[i].value;
      }
    }

    final averageActivity = subjects.isEmpty
        ? 0.0
        : lineAccumulator
                  .map((point) => point / subjects.length)
                  .reduce((a, b) => a + b) /
              lineAccumulator.length;
    final activityTrend = lineAccumulator
        .map<double>(
          (point) => subjects.isEmpty ? 0.0 : point / subjects.length,
        )
        .toList(growable: false);

    final distributionColors = [
      SubjectsManagementPalette.accent,
      SubjectsManagementPalette.teal,
      SubjectsManagementPalette.violet,
      SubjectsManagementPalette.coral,
    ];

    final departmentItems = departmentCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final yearItems = yearCounts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 1100;
            return Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.lg,
              children: [
                SizedBox(
                  width: compact
                      ? constraints.maxWidth
                      : math.max(440, constraints.maxWidth * 0.34),
                  child: _AnalyticsHeroCard(
                    subjectsCount: subjects.length,
                    totalEnrollment: totalEnrollment,
                    averageActivity: averageActivity,
                    activityTrend: activityTrend,
                  ),
                ),
                SizedBox(
                  width: compact
                      ? constraints.maxWidth
                      : math.max(280, constraints.maxWidth * 0.19),
                  child: SubjectMetricTile(
                    label: 'Assigned doctors',
                    value: '${doctors.length}',
                    caption: 'Across all created subjects',
                    icon: Icons.badge_rounded,
                    color: SubjectsManagementPalette.accent,
                  ),
                ),
                SizedBox(
                  width: compact
                      ? constraints.maxWidth
                      : math.max(280, constraints.maxWidth * 0.19),
                  child: SubjectMetricTile(
                    label: 'Assigned assistants',
                    value: '${assistants.length}',
                    caption: 'Teaching support linked',
                    icon: Icons.support_agent_rounded,
                    color: SubjectsManagementPalette.teal,
                  ),
                ),
                SizedBox(
                  width: compact
                      ? constraints.maxWidth
                      : math.max(280, constraints.maxWidth * 0.19),
                  child: SubjectMetricTile(
                    label: 'Active groups',
                    value: '$groups',
                    caption: '$posts posts and $summaries summaries live',
                    icon: Icons.forum_rounded,
                    color: SubjectsManagementPalette.violet,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        LayoutBuilder(
          builder: (context, constraints) {
            final singleColumn = constraints.maxWidth < 1160;
            final chartWidth = singleColumn
                ? constraints.maxWidth
                : (constraints.maxWidth - AppSpacing.lg * 2) / 3;
            return Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.lg,
              children: [
                SizedBox(
                  width: chartWidth,
                  child: _ChartCard(
                    title: 'Subjects by department',
                    subtitle: 'Distribution of created subjects',
                    child: SubjectsDepartmentDonutChart(
                      items: [
                        for (var i = 0; i < departmentItems.length; i++)
                          DepartmentDistributionItem(
                            label: departmentItems[i].key,
                            value: departmentItems[i].value,
                            color:
                                distributionColors[i %
                                    distributionColors.length],
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: chartWidth,
                  child: _ChartCard(
                    title: 'Subjects by academic year',
                    subtitle: 'Cleaner scan for planning density',
                    child: SubjectsYearBarsChart(
                      items: [
                        for (var i = 0; i < yearItems.length; i++)
                          YearBarItem(
                            label: yearItems[i].key.replaceFirst('Year ', 'Y'),
                            value: yearItems[i].value,
                            color: distributionColors.reversed
                                .toList()[i % distributionColors.length],
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: chartWidth,
                  child: _ChartCard(
                    title: 'Activity level',
                    subtitle: 'Posts, summaries, and engagement signal',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            SubjectInfoPill(
                              label: 'Total subjects',
                              value: '${subjects.length}',
                              tint: SubjectsManagementPalette.accent,
                            ),
                            SubjectInfoPill(
                              label: 'Enrolled',
                              value: '$totalEnrollment',
                              tint: SubjectsManagementPalette.coral,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SubjectsActivityLineChart(
                          values: activityTrend,
                          color: SubjectsManagementPalette.coral,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AnalyticsHeroCard extends StatelessWidget {
  const _AnalyticsHeroCard({
    required this.subjectsCount,
    required this.totalEnrollment,
    required this.averageActivity,
    required this.activityTrend,
  });

  final int subjectsCount;
  final int totalEnrollment;
  final double averageActivity;
  final List<double> activityTrend;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      interactive: true,
      backgroundColor: Theme.of(context).cardColor.withValues(alpha: 0.96),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: SubjectsManagementPalette.heroGradient(context),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SubjectToneBadge('Premium control center'),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Subjects / Course Management',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Compact operational view for staff assignment, private enrollment visibility, community control, access links, and content activity.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  SubjectInfoPill(
                    label: 'Subjects created',
                    value: '$subjectsCount',
                    tint: SubjectsManagementPalette.accent,
                  ),
                  SubjectInfoPill(
                    label: 'Student enrollment',
                    value: '$totalEnrollment',
                    tint: SubjectsManagementPalette.teal,
                  ),
                  SubjectInfoPill(
                    label: 'Activity score',
                    value: averageActivity.toStringAsFixed(0),
                    tint: SubjectsManagementPalette.violet,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SubjectsActivityLineChart(
                values: activityTrend,
                color: SubjectsManagementPalette.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SubjectSectionFrame(title: title, subtitle: subtitle, child: child);
  }
}
