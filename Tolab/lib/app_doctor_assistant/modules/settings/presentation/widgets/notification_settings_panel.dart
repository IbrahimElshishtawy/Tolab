import 'package:flutter/material.dart';

import '../../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../../../app/localization/app_localizations.dart';

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
      title: context.l10n.byValue('Notification settings'),
      subtitle: context.l10n.byValue(
          'Control push, email, reminder, quiz, and lecture alerts that drive the teaching workflow.'),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: pushEnabled,
            title: Text(context.l10n.byValue('Push notifications')),
            onChanged: onPushChanged,
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: emailEnabled,
            title: Text(context.l10n.byValue('Email notifications')),
            onChanged: onEmailChanged,
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: remindersEnabled,
            title: Text(context.l10n.byValue('Deadline reminders')),
            onChanged: onRemindersChanged,
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: quizAlertsEnabled,
            title: Text(context.l10n.byValue('Quiz alerts')),
            onChanged: onQuizAlertsChanged,
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: lectureAlertsEnabled,
            title: Text(context.l10n.byValue('Lecture alerts')),
            onChanged: onLectureAlertsChanged,
          ),
        ],
      ),
    );
  }
}
