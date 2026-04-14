import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import '../theme/app_spacing.dart';
import '../theme/dashboard_theme_tokens.dart';
import 'dashboard_section_primitives.dart';

class StudentsAttentionSection extends StatelessWidget {
  const StudentsAttentionSection({
    super.key,
    required this.section,
    required this.onOpenRoute,
  });

  final DashboardStudentsAttention section;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    if (section.items.isEmpty) {
      return const DashboardSectionCard(
        title: 'Students Needing Attention',
        child: DashboardSectionEmpty(
          message: 'No students are currently escalated for follow-up.',
        ),
      );
    }

    final tokens = DashboardThemeTokens.of(context);
    return DashboardSectionCard(
      title: 'Students Needing Attention',
      subtitle: '${section.count} students on the current watchlist.',
      child: Column(
        children: section.items
            .map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: DashboardAppSpacing.sm),
                padding: const EdgeInsets.all(DashboardAppSpacing.md),
                decoration: BoxDecoration(
                  color: tokens.surfaceAlt,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: tokens.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: tokens.textPrimary),
                          ),
                        ),
                        DashboardToneBadge(
                          label: item.severity,
                          tone: item.severity,
                        ),
                      ],
                    ),
                    const SizedBox(height: DashboardAppSpacing.xs),
                    Text(
                      item.reason,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tokens.textSecondary,
                      ),
                    ),
                    if (item.details.isNotEmpty) ...[
                      const SizedBox(height: DashboardAppSpacing.sm),
                      Wrap(
                        spacing: DashboardAppSpacing.xs,
                        runSpacing: DashboardAppSpacing.xs,
                        children: item.details
                            .map(
                              (detail) => DashboardToneBadge(
                                label: detail,
                                tone: item.severity,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: DashboardAppSpacing.sm),
                    DashboardInlineAction(
                      label: item.ctaLabel,
                      onTap: () => onOpenRoute(item.route),
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
