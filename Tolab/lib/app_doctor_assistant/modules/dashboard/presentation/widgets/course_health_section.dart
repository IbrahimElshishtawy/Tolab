import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import 'dashboard_section_primitives.dart';

class CourseHealthSection extends StatelessWidget {
  const CourseHealthSection({super.key, required this.health});

  final DashboardCourseHealth health;

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      title: 'Course Health Score',
      subtitle: health.summary,
      trailing: DashboardToneBadge(label: health.status, tone: health.status),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardMiniMetricCard(
            label: 'Overall score',
            value: '${health.overallScore}',
            tone: health.status,
          ),
          const SizedBox(height: 12),
          DashboardMetricWrap(
            children: health.metrics
                .map(
                  (metric) => DashboardMiniMetricCard(
                    label: metric.label,
                    value: metric.value,
                    tone: metric.tone,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
