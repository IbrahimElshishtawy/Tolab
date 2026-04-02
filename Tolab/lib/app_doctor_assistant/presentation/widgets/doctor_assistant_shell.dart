import 'package:flutter/material.dart';

import '../../../app/core/app_scope.dart';
import '../../../app_admin/core/widgets/adaptive_scaffold.dart';
import '../../core/models/session_user.dart';
import '../../core/navigation/app_routes.dart';
import '../../mock/doctor_assistant_mock_repository.dart';

class DoctorAssistantShell extends StatelessWidget {
  const DoctorAssistantShell({
    super.key,
    required this.user,
    required this.activeRoute,
    required this.child,
  });

  final SessionUser user;
  final String activeRoute;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final repository = DoctorAssistantMockRepository.instance;

    return AdaptiveScaffold(
      location: activeRoute,
      destinations: const [
        NavigationDestinationItem(
          label: 'Home',
          route: AppRoutes.dashboard,
          icon: Icons.dashboard_rounded,
        ),
        NavigationDestinationItem(
          label: 'Subjects',
          route: AppRoutes.subjects,
          icon: Icons.menu_book_rounded,
        ),
        NavigationDestinationItem(
          label: 'Add Lecture',
          route: AppRoutes.lectures,
          icon: Icons.co_present_rounded,
        ),
        NavigationDestinationItem(
          label: 'Add Section',
          route: AppRoutes.sectionContent,
          icon: Icons.widgets_rounded,
        ),
        NavigationDestinationItem(
          label: 'Add Quiz',
          route: AppRoutes.quizzes,
          icon: Icons.quiz_rounded,
        ),
        NavigationDestinationItem(
          label: 'Add Task',
          route: AppRoutes.tasks,
          icon: Icons.assignment_rounded,
        ),
        NavigationDestinationItem(
          label: 'Schedule',
          route: AppRoutes.schedule,
          icon: Icons.calendar_month_rounded,
        ),
        NavigationDestinationItem(
          label: 'Notifications',
          route: AppRoutes.notifications,
          icon: Icons.notifications_active_rounded,
        ),
        NavigationDestinationItem(
          label: 'Profile',
          route: AppRoutes.staff,
          icon: Icons.badge_rounded,
        ),
        NavigationDestinationItem(
          label: 'Settings',
          route: AppRoutes.settings,
          icon: Icons.tune_rounded,
        ),
      ],
      userName: user.fullName,
      userRole: user.roleType,
      unreadNotifications: repository.unreadNotificationsFor(user),
      notificationStatus: user.isDoctor
          ? 'Teaching sync live'
          : 'Assistant sync live',
      notificationRoute: AppRoutes.notifications,
      onToggleTheme: AppScope.theme(context).toggle,
      onLogout: AppScope.auth(context).logout,
      child: child,
    );
  }
}
