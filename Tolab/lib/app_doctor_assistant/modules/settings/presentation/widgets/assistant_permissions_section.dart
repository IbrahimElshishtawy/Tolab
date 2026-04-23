import 'package:flutter/material.dart';

import '../../../../presentation/widgets/doctor_assistant_widgets.dart';

class AssistantPermissionsSection extends StatelessWidget {
  const AssistantPermissionsSection({
    super.key,
    required this.canEditContent,
    required this.canPublishPosts,
    required this.canManageGrades,
    required this.scopeLabel,
    required this.onEditContentChanged,
    required this.onPublishPostsChanged,
    required this.onManageGradesChanged,
    required this.onScopeLabelChanged,
  });

  final bool canEditContent;
  final bool canPublishPosts;
  final bool canManageGrades;
  final String scopeLabel;
  final ValueChanged<bool> onEditContentChanged;
  final ValueChanged<bool> onPublishPostsChanged;
  final ValueChanged<bool> onManageGradesChanged;
  final ValueChanged<String> onScopeLabelChanged;

  @override
  Widget build(BuildContext context) {
    return DoctorAssistantPanel(
      title: 'Assistant permissions',
      subtitle:
          'Define what assistants can edit, publish, or submit inside the doctor-owned academic scope.',
      child: Column(
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: canEditContent,
            title: const Text('Assistant can edit lectures / sections'),
            onChanged: onEditContentChanged,
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: canPublishPosts,
            title: const Text('Assistant can publish announcements / posts'),
            onChanged: onPublishPostsChanged,
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: canManageGrades,
            title: const Text('Assistant can manage grade entries'),
            onChanged: onManageGradesChanged,
          ),
          TextFormField(
            initialValue: scopeLabel,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Assigned scope note',
              hintText: 'Clarify what the assistant can handle inside this course.',
            ),
            onChanged: onScopeLabelChanged,
          ),
        ],
      ),
    );
  }
}
