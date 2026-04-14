import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import '../theme/app_spacing.dart';
import '../theme/dashboard_theme_tokens.dart';
import 'dashboard_section_primitives.dart';
import 'dashboard_view_helpers.dart';

class SmartTimelineSection extends StatelessWidget {
  const SmartTimelineSection({
    super.key,
    required this.timeline,
    required this.onOpenRoute,
  });

  final DashboardTimeline timeline;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final groups = nonEmptyTimelineGroups(timeline);
    if (groups.isEmpty) {
      return const DashboardSectionCard(
        title: 'Smart Timeline',
        child: DashboardSectionEmpty(
          message:
              'No timeline events are scheduled across today and this week.',
        ),
      );
    }

    final tokens = DashboardThemeTokens.of(context);
    return DashboardSectionCard(
      title: 'Smart Timeline',
      subtitle: 'Today, tomorrow, and the rest of this teaching week.',
      child: Column(
        children: groups
            .map(
              (group) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: DashboardAppSpacing.md),
                padding: const EdgeInsets.all(DashboardAppSpacing.md),
                decoration: BoxDecoration(
                  color: tokens.surfaceAlt,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: tokens.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardToneBadge(label: group.label, tone: 'secondary'),
                    const SizedBox(height: DashboardAppSpacing.sm),
                    ...group.items.map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          dashboardIconForTimelineType(item.type),
                          color: dashboardToneColor(tokens, item.status),
                        ),
                        title: Text(
                          item.title,
                          style: TextStyle(color: tokens.textPrimary),
                        ),
                        subtitle: Text(
                          '${item.subjectName} • ${item.whenLabel}',
                          style: TextStyle(color: tokens.textSecondary),
                        ),
                        trailing: DashboardToneBadge(
                          label: item.status,
                          tone: item.status,
                        ),
                        onTap: () => onOpenRoute(item.route),
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
