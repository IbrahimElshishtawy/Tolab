import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import '../theme/app_spacing.dart';
import '../theme/dashboard_theme_tokens.dart';
import 'dashboard_section_primitives.dart';
import 'dashboard_view_helpers.dart';

class ActionCenterSection extends StatelessWidget {
  const ActionCenterSection({
    super.key,
    required this.section,
    required this.onOpenRoute,
  });

  final DashboardActionCenter section;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    if (section.items.isEmpty) {
      return DashboardSectionCard(
        title: 'Action Center',
        subtitle: section.summary,
        child: const DashboardSectionEmpty(
          message: 'No urgent academic actions are waiting right now.',
        ),
      );
    }

    final tokens = DashboardThemeTokens.of(context);
    return DashboardSectionCard(
      title: 'Action Center',
      subtitle: section.summary,
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: dashboardToneColor(
                        tokens,
                        item.priority,
                      ).withValues(alpha: .14),
                      foregroundColor: dashboardToneColor(
                        tokens,
                        item.priority,
                      ),
                      child: Icon(dashboardIconForActionType(item.type)),
                    ),
                    const SizedBox(width: DashboardAppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: tokens.textPrimary),
                                ),
                              ),
                              DashboardToneBadge(
                                label: item.priority,
                                tone: item.priority,
                              ),
                            ],
                          ),
                          const SizedBox(height: DashboardAppSpacing.xs),
                          Text(
                            item.explanation,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: tokens.textSecondary),
                          ),
                          const SizedBox(height: DashboardAppSpacing.sm),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: DashboardInlineAction(
                              label: item.ctaLabel,
                              onTap: () => onOpenRoute(item.route),
                            ),
                          ),
                        ],
                      ),
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
