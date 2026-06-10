import 'package:flutter/material.dart';

import '../../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../../../app/localization/app_localizations.dart';

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
      title: context.l10n.byValue('Assistant permissions'),
      subtitle: context.l10n.byValue(
          'Define what assistants can edit, publish, or submit inside the doctor-owned academic scope.'),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: canEditContent,
            title: Text(context.l10n.byValue('Assistant can edit lectures / sections')),
            onChanged: onEditContentChanged,
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: canPublishPosts,
            title: Text(context.l10n.byValue('Assistant can publish announcements / posts')),
            onChanged: onPublishPostsChanged,
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: canManageGrades,
            title: Text(context.l10n.byValue('Assistant can manage grade entries')),
            onChanged: onManageGradesChanged,
          ),
          TextFormField(
            initialValue: scopeLabel,
            minLines: 2,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: context.l10n.byValue('Assigned scope note'),
              hintText: context.l10n.byValue('Clarify what the assistant can handle inside this course.'),
            ),
            onChanged: onScopeLabelChanged,
          ),
        ],
      ),
    );
  }
}
