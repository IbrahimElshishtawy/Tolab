import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import 'dashboard_section_primitives.dart';

class StudentActivityInsightsSection extends StatelessWidget {
  const StudentActivityInsightsSection({
    super.key,
    required this.insights,
  });

  final DashboardStudentActivityInsights insights;

  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      title: 'Student Activity Insights',
      subtitle: insights.summary,
      child: DashboardMetricWrap(
        children: [
          DashboardMiniMetricCard(
            label: 'Active today',
            value: '${insights.activeStudents}',
            tone: 'success',
          ),
          DashboardMiniMetricCard(
            label: 'Inactive',
            value: '${insights.inactiveStudents}',
            tone: insights.inactiveStudents > 0 ? 'warning' : 'success',
          ),
          DashboardMiniMetricCard(
            label: 'Missing submissions',
            value: '${insights.missingSubmissions}',
            tone: insights.missingSubmissions > 0 ? 'danger' : 'success',
          ),
          DashboardMiniMetricCard(
            label: 'Engagement',
            value: '${insights.engagementRate}%',
            tone: insights.engagementRate >= 70 ? 'success' : 'warning',
          ),
        ],
      ),
    );
  }
}
