import 'package:flutter/material.dart';

import '../../../app/core/app_scope.dart';
import '../../../app_admin/core/widgets/adaptive_scaffold.dart';
import '../../core/models/session_user.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/navigation/navigation_items.dart';

class DoctorAssistantShell extends StatelessWidget {
  const DoctorAssistantShell({
    super.key,
    required this.user,
    required this.activeRoute,
    required this.child,
    this.unreadNotifications = 0,
  });

  final SessionUser user;
  final String activeRoute;
  final Widget child;
  final int unreadNotifications;

  @override
  Widget build(BuildContext context) {
    final localeController = AppScope.locale(context);

    return AdaptiveScaffold(
      location: activeRoute,
      destinations: buildNavigationItems(user)
          .map(
            (item) => NavigationDestinationItem(
              label: item.label,
              route: item.path,
              icon: item.icon,
            ),
          )
          .toList(),
      userName: user.fullName,
      userRole: user.roleType,
      unreadNotifications: unreadNotifications,
      notificationStatus: user.isDoctor
          ? 'Teaching sync live'
          : 'Assistant sync live',
      notificationRoute: AppRoutes.notifications,
      onToggleTheme: AppScope.theme(context).toggle,
      languageCode: localeController.languageCode,
      onLanguageSelected: localeController.setLanguage,
      onLogout: AppScope.auth(context).logout,
      child: child,
    );
  }
}
