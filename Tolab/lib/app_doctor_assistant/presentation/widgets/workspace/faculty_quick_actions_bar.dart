import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../../app_admin/core/widgets/app_card.dart';
import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';

class FacultyQuickActionsBar extends StatelessWidget {
  const FacultyQuickActionsBar({
    super.key,
    required this.user,
    this.title = 'Quick actions',
    this.subtitle =
        'Jump to the most common academic actions without leaving the current workspace.',
  });

  final SessionUser user;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickAction>[
      if (user.hasPermission('lectures.create'))
        const _QuickAction(
          label: 'Add Lecture',
          icon: Icons.slideshow_rounded,
          route: AppRoutes.addLecture,
        ),
      if (user.hasPermission('quizzes.create'))
        const _QuickAction(
          label: 'Add Quiz',
          icon: Icons.quiz_rounded,
          route: AppRoutes.quizzes,
        ),
      if (user.hasPermission('community.post'))
        const _QuickAction(
          label: 'Add Post',
          icon: Icons.campaign_rounded,
          route: AppRoutes.announcements,
        ),
      if (user.hasPermission('tasks.create'))
        const _QuickAction(
          label: 'Add Task',
          icon: Icons.task_alt_rounded,
          route: AppRoutes.tasks,
        ),
      if (user.hasPermission('students.view'))
        const _QuickAction(
          label: 'View Students',
          icon: Icons.school_rounded,
          route: AppRoutes.students,
        ),
    ];

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: actions
                .map(
                  (action) => FilledButton.tonalIcon(
                    onPressed: () => context.go(action.route),
                    icon: Icon(action.icon),
                    label: Text(action.label),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}
