import 'package:flutter/material.dart';

import '../../../app/core/app_scope.dart';
import '../../core/models/session_user.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/navigation/navigation_items.dart';
import 'responsive_scaffold.dart';

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
    final navigation = buildDoctorAssistantNavigationConfig(user);

    return ResponsiveScaffold(
      location: activeRoute,
      navigation: navigation,
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
