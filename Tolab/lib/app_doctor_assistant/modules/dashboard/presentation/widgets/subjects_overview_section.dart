import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import '../theme/app_spacing.dart';
import '../theme/dashboard_theme_tokens.dart';
import 'dashboard_section_primitives.dart';

class SubjectsOverviewSection extends StatelessWidget {
  const SubjectsOverviewSection({
    super.key,
    required this.section,
    required this.onOpenRoute,
  });

  final DashboardSubjectsOverview section;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    if (section.items.isEmpty) {
      return DashboardSectionCard(
        title: 'Subjects Overview',
        child: DashboardSectionEmpty(message: section.summary),
      );
    }

    final tokens = DashboardThemeTokens.of(context);
    return DashboardSectionCard(
      title: 'Subjects Overview',
      subtitle: section.summary,
      child: Column(
        children: section.items
            .map(
              (subject) => Container(
                margin: const EdgeInsets.only(bottom: DashboardAppSpacing.sm),
                padding: const EdgeInsets.all(DashboardAppSpacing.md),
                decoration: BoxDecoration(
                  color: tokens.surfaceAlt,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: tokens.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: tokens.textPrimary),
                              ),
                              const SizedBox(height: DashboardAppSpacing.xs),
                              Text(
                                '${subject.code} • ${subject.department} • ${subject.batch}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: tokens.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        DashboardToneBadge(
                          label: '${subject.healthScore}',
                          tone: subject.riskLevel,
                        ),
                      ],
                    ),
                    const SizedBox(height: DashboardAppSpacing.sm),
                    DashboardMetricWrap(
                      children: [
                        DashboardMiniMetricCard(
                          label: 'Students',
                          value: '${subject.studentCount}',
                          tone: 'primary',
                        ),
                        DashboardMiniMetricCard(
                          label: 'Groups',
                          value: '${subject.groupsCount}',
                          tone: 'secondary',
                        ),
                        DashboardMiniMetricCard(
                          label: 'Sections',
                          value: '${subject.sectionsCount}',
                          tone: 'success',
                        ),
                      ],
                    ),
                    const SizedBox(height: DashboardAppSpacing.sm),
                    Wrap(
                      spacing: DashboardAppSpacing.xs,
                      runSpacing: DashboardAppSpacing.xs,
                      children: subject.quickActions
                          .map(
                            (action) => OutlinedButton(
                              onPressed: () => onOpenRoute(action.route),
                              child: Text(action.label),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
