import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../../app/core/app_scope.dart';
import '../../../app_admin/core/routing/route_paths.dart';
import '../../../app_admin/core/widgets/adaptive_scaffold.dart';
import '../../../app_admin/modules/notifications/presentation/widgets/notification_toast_host.dart';
import '../../../app_admin/state/app_state.dart';
import '../../../app_admin/shared/models/notification_models.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bootstrap = AppScope.read(context);
    final auth = bootstrap.authController;
    final theme = bootstrap.themeController;

    return StoreProvider<AppState>(
      store: bootstrap.adminStore,
      child: StoreConnector<AppState, _AdminShellViewModel>(
        converter: (store) => _AdminShellViewModel.fromStore(
          store,
          authName: auth.currentUser?.fullName,
          authRole: auth.currentUser?.role.value,
        ),
        builder: (context, vm) {
          return Stack(
            children: [
              AdaptiveScaffold(
                location: location,
                destinations: _destinations,
                userName: vm.userName,
                userRole: vm.userRole,
                unreadNotifications: vm.unreadNotifications,
                notificationStatus: vm.notificationStatus,
                notificationRoute: RoutePaths.notifications,
                onToggleTheme: theme.toggle,
                languageCode: AppScope.locale(context).languageCode,
                onLanguageSelected: AppScope.locale(context).setLanguage,
                onLogout: auth.logout,
                child: child,
              ),
              const NotificationToastHost(),
            ],
          );
        },
      ),
    );
  }

  static const List<NavigationDestinationItem> _destinations =
      <NavigationDestinationItem>[
        NavigationDestinationItem(
          label: 'dashboard',
          route: RoutePaths.dashboard,
          icon: Icons.dashboard_rounded,
        ),
        NavigationDestinationItem(
          label: 'students',
          route: RoutePaths.students,
          icon: Icons.school_rounded,
        ),
        NavigationDestinationItem(
          label: 'staff',
          route: RoutePaths.staff,
          icon: Icons.groups_rounded,
        ),
        NavigationDestinationItem(
          label: 'departments',
          route: RoutePaths.departments,
          icon: Icons.apartment_rounded,
        ),
        NavigationDestinationItem(
          label: 'sections',
          route: RoutePaths.sections,
          icon: Icons.dashboard_customize_rounded,
        ),
        NavigationDestinationItem(
          label: 'subjects',
          route: RoutePaths.subjects,
          icon: Icons.auto_stories_rounded,
        ),
        NavigationDestinationItem(
          label: 'offerings',
          route: RoutePaths.courseOfferings,
          icon: Icons.add_chart_rounded,
        ),
        NavigationDestinationItem(
          label: 'enrollments',
          route: RoutePaths.enrollments,
          icon: Icons.assignment_turned_in_rounded,
        ),
        NavigationDestinationItem(
          label: 'content',
          route: RoutePaths.content,
          icon: Icons.edit_note_rounded,
        ),
        NavigationDestinationItem(
          label: 'schedule',
          route: RoutePaths.schedule,
          icon: Icons.calendar_month_rounded,
        ),
        NavigationDestinationItem(
          label: 'uploads',
          route: RoutePaths.uploads,
          icon: Icons.cloud_upload_rounded,
        ),
        NavigationDestinationItem(
          label: 'notifications',
          route: RoutePaths.notifications,
          icon: Icons.notifications_active_rounded,
        ),
        NavigationDestinationItem(
          label: 'moderation',
          route: RoutePaths.moderation,
          icon: Icons.shield_rounded,
        ),
        NavigationDestinationItem(
          label: 'roles',
          route: RoutePaths.roles,
          icon: Icons.admin_panel_settings_rounded,
        ),
        NavigationDestinationItem(
          label: 'settings',
          route: RoutePaths.settings,
          icon: Icons.tune_rounded,
        ),
      ];
}

class _AdminShellViewModel {
  const _AdminShellViewModel({
    required this.userName,
    required this.userRole,
    required this.unreadNotifications,
    required this.notificationStatus,
  });

  final String userName;
  final String userRole;
  final int unreadNotifications;
  final String notificationStatus;

  factory _AdminShellViewModel.fromStore(
    Store<AppState> store, {
    String? authName,
    String? authRole,
  }) {
    return _AdminShellViewModel(
      userName: authName ?? store.state.authState.currentUser?.name ?? 'Admin',
      userRole: authRole ?? store.state.authState.currentUser?.role ?? 'admin',
      unreadNotifications: store.state.notificationsState.unreadCount,
      notificationStatus: store.state.notificationsState.connectionStatus.label,
    );
  }
}
