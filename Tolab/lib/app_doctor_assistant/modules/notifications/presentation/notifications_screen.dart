import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/navigation/navigation_items.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/state_views.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';
import '../state/notifications_actions.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _NotificationsVm>(
      converter: (store) => _NotificationsVm.fromStore(store),
      onInit: (store) => store.dispatch(LoadNotificationsAction()),
      builder: (context, vm) {
        final user = vm.user;
        if (user == null) return const SizedBox.shrink();

        return AppShell(
          user: user,
          title: 'Notifications',
          activePath: AppRoutes.notifications,
          items: buildNavigationItems(user),
          body: vm.items == null
              ? const LoadingStateView()
              : ListView(
                  children: vm.items!
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () => vm.markRead(item.id),
                            child: AppCard(
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(item.title),
                                subtitle: Text(item.body),
                                trailing: AppBadge(
                                  label: item.isRead ? 'Read' : 'Unread',
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        );
      },
    );
  }
}

class _NotificationsVm {
  const _NotificationsVm({
    required this.user,
    required this.items,
    required this.markRead,
  });

  final SessionUser? user;
  final List<NotificationModel>? items;
  final void Function(int id) markRead;

  factory _NotificationsVm.fromStore(Store<DoctorAssistantAppState> store) {
    return _NotificationsVm(
      user: getCurrentUser(store.state),
      items: store.state.notificationsState.data,
      markRead: (id) => store.dispatch(MarkNotificationReadAction(id)),
    );
  }
}
