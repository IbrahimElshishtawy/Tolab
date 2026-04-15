import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';

import '../../../app/core/app_scope.dart';
import '../../modules/auth/presentation/login_screen.dart';
import '../../modules/auth/state/auth_state.dart';
import '../../modules/content_management/presentation/content_screen.dart';
import '../../modules/course_offerings/presentation/pages/course_offering_details_page.dart';
import '../../modules/course_offerings/presentation/course_offerings_screen.dart';
import '../../modules/dashboard/presentation/dashboard_screen.dart';
import '../../modules/departments/presentation/department_details_screen.dart';
import '../../modules/departments/presentation/departments_screen.dart';
import '../../modules/enrollments/presentation/enrollments_screen.dart';
import '../../modules/moderation/presentation/moderation_screen.dart';
import '../../modules/notifications/presentation/notifications_screen.dart';
import '../../modules/roles_permissions/presentation/roles_screen.dart';
import '../../modules/schedule/presentation/schedule_screen.dart';
import '../../modules/sections/presentation/sections_screen.dart';
import '../../modules/settings/presentation/settings_screen.dart';
import '../../modules/settings/state/settings_actions.dart';
import '../../modules/splash/presentation/splash_screen.dart';
import '../../modules/staff/presentation/staff_screen.dart';
import '../../modules/students/presentation/students_screen.dart';
import '../../modules/subjects/presentation/subjects_screen.dart';
import '../../modules/uploads/presentation/uploads_screen.dart';
import '../../shared/models/notification_models.dart';
import '../../state/app_state.dart';
import '../widgets/adaptive_scaffold.dart';
import 'route_paths.dart';

class AppRouter {
  AppRouter(this._store) {
    router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: RoutePaths.splash,
      refreshListenable: _StoreRefreshListenable(_store),
      redirect: (context, state) {
        final appState = _store.state;
        final isBootstrapped = appState.bootstrapState.isReady;
        final isAuthenticated = appState.authState.isAuthenticated;
        final isSplash = state.uri.path == RoutePaths.splash;
        final isLogin = state.uri.path == RoutePaths.login;

        if (!isBootstrapped && !isSplash) {
          return RoutePaths.splash;
        }
        if (isBootstrapped && !isAuthenticated && !isLogin) {
          return RoutePaths.login;
        }
        if (isBootstrapped && isAuthenticated && (isSplash || isLogin)) {
          return RoutePaths.dashboard;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: RoutePaths.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: RoutePaths.login,
          builder: (context, state) => const LoginScreen(),
        ),
        _shellPageRoute(
          path: RoutePaths.dashboard,
          child: const DashboardScreen(),
        ),
        _shellPageRoute(
          path: RoutePaths.students,
          child: const StudentsScreen(),
        ),
        _shellPageRoute(path: RoutePaths.staff, child: const StaffScreen()),
        _shellPageRoute(
          path: RoutePaths.departmentDetailsPattern,
          builder: (state) => DepartmentDetailsScreen(
            departmentId: state.pathParameters['departmentId'] ?? '',
          ),
        ),
        _shellPageRoute(
          path: RoutePaths.departments,
          child: const DepartmentsScreen(),
        ),
        _shellPageRoute(
          path: RoutePaths.sections,
          child: const SectionsScreen(),
        ),
        _shellPageRoute(
          path: RoutePaths.subjects,
          child: const SubjectsScreen(),
        ),
        _shellPageRoute(
          path: RoutePaths.courseOfferingDetailsPattern,
          builder: (state) => CourseOfferingDetailsPage(
            offeringId: state.pathParameters['offeringId'] ?? '',
          ),
        ),
        _shellPageRoute(
          path: RoutePaths.courseOfferings,
          child: const CourseOfferingsScreen(),
        ),
        _shellPageRoute(
          path: RoutePaths.enrollments,
          child: const EnrollmentsScreen(),
        ),
        _shellPageRoute(path: RoutePaths.content, child: const ContentScreen()),
        _shellPageRoute(
          path: RoutePaths.schedule,
          child: const ScheduleScreen(),
        ),
        _shellPageRoute(path: RoutePaths.uploads, child: const UploadsScreen()),
        _shellPageRoute(
          path: RoutePaths.notifications,
          child: const NotificationsScreen(),
        ),
        _shellPageRoute(
          path: RoutePaths.notificationsHistory,
          child: const NotificationsScreen(initialTabIndex: 1),
        ),
        _shellPageRoute(
          path: RoutePaths.moderation,
          child: const ModerationScreen(),
        ),
        _shellPageRoute(path: RoutePaths.roles, child: const RolesScreen()),
        _shellPageRoute(
          path: RoutePaths.settings,
          child: const SettingsScreen(),
        ),
      ],
    );
  }

  final Store<AppState> _store;
  final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'rootNavigator',
  );
  late final GoRouter router;

  GoRoute _shellPageRoute({
    required String path,
    Widget? child,
    Widget Function(GoRouterState state)? builder,
  }) {
    return GoRoute(
      path: path,
      pageBuilder: (context, state) => NoTransitionPage<void>(
        key: state.pageKey,
        restorationId: state.pageKey.value,
        child: _buildShell(context, state, builder?.call(state) ?? child!),
      ),
    );
  }

  Widget _buildShell(BuildContext context, GoRouterState state, Widget child) {
    final localeController = AppScope.locale(context);
    return StoreConnector<AppState, _ShellViewModel>(
      converter: (store) => _ShellViewModel(
        userName: store.state.authState.currentUser?.name ?? 'Admin',
        userRole: store.state.authState.currentUser?.role ?? 'Administrator',
        unreadNotifications: store.state.notificationsState.unreadCount,
        notificationStatus:
            store.state.notificationsState.connectionStatus.label,
      ),
      builder: (context, vm) {
        return AdaptiveScaffold(
          location: state.uri.path,
          destinations: _destinations,
          userName: vm.userName,
          userRole: vm.userRole,
          unreadNotifications: vm.unreadNotifications,
          notificationStatus: vm.notificationStatus,
          notificationRoute: RoutePaths.notifications,
          onToggleTheme: () => StoreProvider.of<AppState>(
            context,
          ).dispatch(ToggleThemeModeAction()),
          languageCode: localeController.languageCode,
          onLanguageSelected: localeController.setLanguage,
          onLogout: () => StoreProvider.of<AppState>(
            context,
          ).dispatch(LogoutRequestedAction()),
          child: child,
        );
      },
    );
  }

  static const List<NavigationDestinationItem> _destinations = [
    NavigationDestinationItem(
      label: 'Dashboard',
      route: RoutePaths.dashboard,
      icon: Icons.dashboard_rounded,
    ),
    NavigationDestinationItem(
      label: 'Students',
      route: RoutePaths.students,
      icon: Icons.school_rounded,
    ),
    NavigationDestinationItem(
      label: 'Staff',
      route: RoutePaths.staff,
      icon: Icons.groups_rounded,
    ),
    NavigationDestinationItem(
      label: 'Departments',
      route: RoutePaths.departments,
      icon: Icons.apartment_rounded,
    ),
    NavigationDestinationItem(
      label: 'Sections',
      route: RoutePaths.sections,
      icon: Icons.dashboard_customize_rounded,
    ),
    NavigationDestinationItem(
      label: 'Subjects',
      route: RoutePaths.subjects,
      icon: Icons.auto_stories_rounded,
    ),
    NavigationDestinationItem(
      label: 'Offerings',
      route: RoutePaths.courseOfferings,
      icon: Icons.add_chart_rounded,
    ),
    NavigationDestinationItem(
      label: 'Enrollments',
      route: RoutePaths.enrollments,
      icon: Icons.assignment_turned_in_rounded,
    ),
    NavigationDestinationItem(
      label: 'Content',
      route: RoutePaths.content,
      icon: Icons.edit_note_rounded,
    ),
    NavigationDestinationItem(
      label: 'Schedule',
      route: RoutePaths.schedule,
      icon: Icons.calendar_month_rounded,
    ),
    NavigationDestinationItem(
      label: 'Uploads',
      route: RoutePaths.uploads,
      icon: Icons.cloud_upload_rounded,
    ),
    NavigationDestinationItem(
      label: 'Notifications',
      route: RoutePaths.notifications,
      icon: Icons.notifications_active_rounded,
    ),
    NavigationDestinationItem(
      label: 'Moderation',
      route: RoutePaths.moderation,
      icon: Icons.shield_rounded,
    ),
    NavigationDestinationItem(
      label: 'Roles',
      route: RoutePaths.roles,
      icon: Icons.admin_panel_settings_rounded,
    ),
    NavigationDestinationItem(
      label: 'Settings',
      route: RoutePaths.settings,
      icon: Icons.tune_rounded,
    ),
  ];
}

class _StoreRefreshListenable extends ChangeNotifier {
  _StoreRefreshListenable(Store<AppState> store) {
    _isBootstrapped = store.state.bootstrapState.isReady;
    _isAuthenticated = store.state.authState.isAuthenticated;
    _subscription = store.onChange.listen((state) {
      final nextIsBootstrapped = state.bootstrapState.isReady;
      final nextIsAuthenticated = state.authState.isAuthenticated;
      if (nextIsBootstrapped == _isBootstrapped &&
          nextIsAuthenticated == _isAuthenticated) {
        return;
      }

      _isBootstrapped = nextIsBootstrapped;
      _isAuthenticated = nextIsAuthenticated;
      notifyListeners();
    });
  }

  late final StreamSubscription<AppState> _subscription;
  late bool _isBootstrapped;
  late bool _isAuthenticated;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class _ShellViewModel {
  const _ShellViewModel({
    required this.userName,
    required this.userRole,
    required this.unreadNotifications,
    required this.notificationStatus,
  });

  final String userName;
  final String userRole;
  final int unreadNotifications;
  final String notificationStatus;
}
