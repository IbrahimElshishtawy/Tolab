import 'package:flutter/material.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../models/analytics_workspace_models.dart';

class AnalyticsStudentsFocusSection extends StatelessWidget {
  const AnalyticsStudentsFocusSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.students,
    required this.highlightColor,
  });

  final String title;
  final String subtitle;
  final List<AnalyticsStudentInsight> students;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    return DoctorAssistantPanel(
      title: title,
      subtitle: subtitle,
      child: Column(
        children: students
            .map(
              (student) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: DoctorAssistantItemCard(
                  icon: Icons.school_rounded,
                  title: student.name,
                  subtitle:
                      '${student.code} • ${student.subjectCode} • ${student.sectionLabel}',
                  meta:
                      'Avg ${student.averageScore.toStringAsFixed(1)}% • Attendance ${student.attendanceRate}% • Engagement ${student.engagementScore} • ${student.lastActiveLabel}',
                  statusLabel: student.riskLabel,
                  highlightColor: highlightColor,
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}
