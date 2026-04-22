import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, SessionUser?>(
      converter: (store) => getCurrentUser(store.state),
      builder: (context, user) {
        if (user == null) return const SizedBox.shrink();
        final notifications = DoctorAssistantMockRepository.instance
            .notificationsFor(user);

        return DoctorAssistantShell(
          user: user,
          activeRoute: AppRoutes.notifications,
          unreadNotifications: DoctorAssistantMockRepository.instance
              .unreadNotificationsFor(user),
          child: DoctorAssistantPageScaffold(
            title: 'Notifications',
            subtitle:
                'List cards keep the same admin spacing, badge treatment, and interaction feel.',
            breadcrumbs: const ['Workspace', 'Notifications'],
            child: Column(
              children: [
                for (final item in notifications) ...[
                  DoctorAssistantItemCard(
                    icon: item.icon,
                    title: item.title,
                    subtitle: item.body,
                    meta: '${item.courseLabel} • ${item.timeLabel}',
                    statusLabel: item.isRead ? 'Completed' : item.statusLabel,
                  ),
                  if (item != notifications.last)
                    const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
