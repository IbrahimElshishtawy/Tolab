import 'package:flutter/material.dart';

import '../../../../presentation/widgets/doctor_assistant_widgets.dart';

class NotificationSettingsPanel extends StatelessWidget {
  const NotificationSettingsPanel({
    super.key,
    required this.pushEnabled,
    required this.emailEnabled,
    required this.remindersEnabled,
    required this.quizAlertsEnabled,
    required this.lectureAlertsEnabled,
    required this.onPushChanged,
    required this.onEmailChanged,
    required this.onRemindersChanged,
    required this.onQuizAlertsChanged,
    required this.onLectureAlertsChanged,
  });

  final bool pushEnabled;
  final bool emailEnabled;
  final bool remindersEnabled;
  final bool quizAlertsEnabled;
  final bool lectureAlertsEnabled;
  final ValueChanged<bool> onPushChanged;
  final ValueChanged<bool> onEmailChanged;
  final ValueChanged<bool> onRemindersChanged;
  final ValueChanged<bool> onQuizAlertsChanged;
  final ValueChanged<bool> onLectureAlertsChanged;

  @override
  Widget build(BuildContext context) {
    return DoctorAssistantPanel(
      title: 'Notification settings',
      subtitle:
          'Control push, email, reminder, quiz, and lecture alerts that drive the teaching workflow.',
      child: Column(
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: pushEnabled,
            title: const Text('Push notifications'),
            onChanged: onPushChanged,
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: emailEnabled,
            title: const Text('Email notifications'),
            onChanged: onEmailChanged,
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: remindersEnabled,
            title: const Text('Deadline reminders'),
            onChanged: onRemindersChanged,
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: quizAlertsEnabled,
            title: const Text('Quiz alerts'),
            onChanged: onQuizAlertsChanged,
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: lectureAlertsEnabled,
            title: const Text('Lecture alerts'),
            onChanged: onLectureAlertsChanged,
          ),
        ],
      ),
    );
  }
}
