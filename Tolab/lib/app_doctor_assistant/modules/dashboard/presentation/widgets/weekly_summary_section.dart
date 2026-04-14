import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import 'dashboard_section_primitives.dart';

class WeeklySummarySection extends StatelessWidget {
  const WeeklySummarySection({super.key, required this.summary});

  final DashboardWeeklySummary summary;

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      title: 'Weekly Summary',
      subtitle: summary.headline,
      child: DashboardMetricWrap(
        children: summary.items
            .map(
              (item) => DashboardMiniMetricCard(
                label: item.label,
                value: item.value,
                tone: item.tone,
                caption: item.caption,
              ),
            )
            .toList(),
      ),
    );
  }
}
