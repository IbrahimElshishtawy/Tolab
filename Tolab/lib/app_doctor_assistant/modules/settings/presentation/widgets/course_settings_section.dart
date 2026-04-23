import 'package:flutter/material.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../presentation/widgets/doctor_assistant_widgets.dart';

class CourseSettingsSection extends StatelessWidget {
  const CourseSettingsSection({
    super.key,
    required this.publishBehavior,
    required this.attendancePolicy,
    required this.quizRule,
    required this.onPublishBehaviorChanged,
    required this.onAttendancePolicyChanged,
    required this.onQuizRuleChanged,
  });

  final String publishBehavior;
  final String attendancePolicy;
  final String quizRule;
  final ValueChanged<String> onPublishBehaviorChanged;
  final ValueChanged<String> onAttendancePolicyChanged;
  final ValueChanged<String> onQuizRuleChanged;

  @override
  Widget build(BuildContext context) {
    return DoctorAssistantPanel(
      title: 'Course settings',
      subtitle:
          'Control grading structure rules, attendance policy, quiz behavior, and how publication should behave.',
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: publishBehavior,
            decoration: const InputDecoration(labelText: 'Publish behavior'),
            items: const [
              DropdownMenuItem(
                value: 'Require review before publish',
                child: Text('Require review before publish'),
              ),
              DropdownMenuItem(
                value: 'Auto publish after save',
                child: Text('Auto publish after save'),
              ),
              DropdownMenuItem(
                value: 'Draft only until doctor approval',
                child: Text('Draft only until doctor approval'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                onPublishBehaviorChanged(value);
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: attendancePolicy,
            decoration: const InputDecoration(labelText: 'Attendance policy'),
            items: const [
              DropdownMenuItem(
                value: 'Warn below 75% attendance',
                child: Text('Warn below 75% attendance'),
              ),
              DropdownMenuItem(
                value: 'Block grade release below 70%',
                child: Text('Block grade release below 70%'),
              ),
              DropdownMenuItem(
                value: 'Track only without penalties',
                child: Text('Track only without penalties'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                onAttendancePolicyChanged(value);
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: quizRule,
            decoration: const InputDecoration(labelText: 'Quiz rule'),
            items: const [
              DropdownMenuItem(
                value: 'Allow one graded attempt',
                child: Text('Allow one graded attempt'),
              ),
              DropdownMenuItem(
                value: 'Allow one retry for practice quizzes',
                child: Text('Allow one retry for practice quizzes'),
              ),
              DropdownMenuItem(
                value: 'Require timed entry and lock late join',
                child: Text('Require timed entry and lock late join'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                onQuizRuleChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
