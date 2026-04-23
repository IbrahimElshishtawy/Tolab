import 'package:flutter/material.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../presentation/widgets/doctor_assistant_widgets.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key, required this.actions});

  final List<QuickActionItem> actions;

  @override
  Widget build(BuildContext context) {
    return DoctorAssistantPanel(
      title: 'Quick actions',
      subtitle:
          'One clean action area for the most common schedule-side teaching tasks.',
      child: actions.isEmpty
          ? Text(
              'No quick actions are available for this account.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          : Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: actions
                  .map(
                    (action) => FilledButton.tonalIcon(
                      onPressed: action.onPressed,
                      icon: Icon(action.icon),
                      label: Text(action.label),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

class QuickActionItem {
  const QuickActionItem({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
}
