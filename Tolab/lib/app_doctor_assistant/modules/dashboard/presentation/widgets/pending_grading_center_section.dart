import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import 'dashboard_section_primitives.dart';

class PendingGradingCenterSection extends StatelessWidget {
  const PendingGradingCenterSection({
    super.key,
    required this.section,
    required this.onOpenRoute,
  });

  final DashboardPendingGrading section;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    if (!section.canManage) {
      return DashboardSectionCard(
        title: 'Pending Grading',
        child: DashboardSectionEmpty(message: section.summary),
      );
    }

    if (section.items.isEmpty) {
      return DashboardSectionCard(
        title: 'Pending Grading',
        child: DashboardSectionEmpty(message: section.summary),
      );
    }

    return DashboardSectionCard(
      title: 'Pending Grading',
      subtitle: section.summary,
      child: Column(
        children: section.items
            .map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.title),
                subtitle: Text(
                  '${item.subjectName} • ${item.pendingCount} waiting',
                ),
                trailing: DashboardInlineAction(
                  label: item.ctaLabel,
                  onTap: () => onOpenRoute(item.route),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
