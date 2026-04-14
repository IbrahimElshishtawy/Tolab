import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import 'dashboard_section_primitives.dart';

class RiskAlertsSection extends StatelessWidget {
  const RiskAlertsSection({
    super.key,
    required this.alerts,
    required this.onOpenRoute,
  });

  final DashboardRiskAlerts alerts;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    if (alerts.items.isEmpty) {
      return const DashboardSectionCard(
        title: 'Risk Alerts',
        child: DashboardSectionEmpty(
          message: 'No active risks are escalating at the moment.',
        ),
      );
    }

    return DashboardSectionCard(
      title: 'Risk Alerts',
      subtitle: '${alerts.count} signals need review.',
      child: Column(
        children: alerts.items
            .map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.title),
                subtitle: Text(item.explanation),
                trailing: DashboardToneBadge(
                  label: item.severity,
                  tone: item.severity,
                ),
                onTap: () => onOpenRoute(item.route),
              ),
            )
            .toList(),
      ),
    );
  }
}
