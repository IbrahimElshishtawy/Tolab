import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import 'dashboard_section_primitives.dart';
import 'dashboard_view_helpers.dart';

class PerformanceAnalyticsSection extends StatelessWidget {
  const PerformanceAnalyticsSection({
    super.key,
    required this.analytics,
  });

  final DashboardPerformanceAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    if (analytics.isLimited ||
        (analytics.averageScore == null &&
            analytics.trend.isEmpty &&
            analytics.topPerformers.isEmpty &&
            analytics.lowPerformers.isEmpty)) {
      return DashboardSectionCard(
        title: 'Performance Analytics',
        child: DashboardSectionEmpty(message: analytics.summary),
      );
    }

    return DashboardSectionCard(
      title: 'Performance Analytics',
      subtitle: analytics.summary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardMiniMetricCard(
            label: 'Average score',
            value: dashboardFormattedPercent(analytics.averageScore),
            tone: (analytics.averageScore ?? 0) >= 70 ? 'success' : 'warning',
          ),
          const SizedBox(height: 12),
          if (analytics.trend.isNotEmpty)
            DashboardMetricWrap(
              children: analytics.trend
                  .map(
                    (point) => DashboardMiniMetricCard(
                      label: point.label,
                      value: dashboardFormattedPercent(point.value),
                      tone: point.value >= 70 ? 'success' : 'warning',
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}
