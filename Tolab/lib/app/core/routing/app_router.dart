import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';

import '../../modules/auth/presentation/login_screen.dart';
import '../../modules/auth/state/auth_state.dart';
import '../../modules/content_management/presentation/content_screen.dart';
import '../../modules/course_offerings/presentation/course_offerings_screen.dart';
import '../../modules/dashboard/presentation/dashboard_screen.dart';
import '../../modules/departments/presentation/departments_screen.dart';
import '../../modules/enrollments/presentation/enrollments_screen.dart';
import '../../modules/moderation/presentation/moderation_screen.dart';
import '../../modules/notifications/presentation/notifications_screen.dart';
import '../../modules/roles_permissions/presentation/roles_screen.dart';
import '../../modules/schedule/presentation/schedule_screen.dart';
import '../../modules/sections/presentation/sections_screen.dart';
import '../../modules/settings/presentation/settings_screen.dart';
import '../../modules/settings/state/settings_state.dart';
import '../../modules/splash/presentation/splash_screen.dart';
import '../../modules/staff/presentation/staff_screen.dart';
import '../../modules/students/presentation/students_screen.dart';
import '../../modules/subjects/presentation/subjects_screen.dart';
import '../../modules/uploads/presentation/uploads_screen.dart';
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
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          pageBuilder: (context, state, child) => NoTransitionPage<void>(
            key: ValueKey<String>('shell:${state.uri.path}'),
            restorationId: 'shell:${state.uri.path}',
            child: _buildShell(context, state, child),
          ),
          routes: [
            GoRoute(
              path: RoutePaths.dashboard,
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: RoutePaths.students,
              builder: (context, state) => const StudentsScreen(),
            ),
            GoRoute(
              path: RoutePaths.staff,
              builder: (context, state) => const StaffScreen(),
            ),
            GoRoute(
              path: RoutePaths.departments,
              builder: (context, state) => const DepartmentsScreen(),
            ),
            GoRoute(
              path: RoutePaths.sections,
              builder: (context, state) => const SectionsScreen(),
            ),
            GoRoute(
              path: RoutePaths.subjects,
              builder: (context, state) => const SubjectsScreen(),
            ),
            GoRoute(
              path: RoutePaths.courseOfferings,
              builder: (context, state) => const CourseOfferingsScreen(),
            ),
            GoRoute(
              path: RoutePaths.enrollments,
              builder: (context, state) => const EnrollmentsScreen(),
            ),
            GoRoute(
              path: RoutePaths.content,
              builder: (context, state) => const ContentScreen(),
            ),
            GoRoute(
              path: RoutePaths.schedule,
              builder: (context, state) => const ScheduleScreen(),
            ),
            GoRoute(
              path: RoutePaths.uploads,
              builder: (context, state) => const UploadsScreen(),
            ),
            GoRoute(
              path: RoutePaths.notifications,
              builder: (context, state) => const NotificationsScreen(),
            ),
            GoRoute(
              path: RoutePaths.moderation,
              builder: (context, state) => const ModerationScreen(),
            ),
            GoRoute(
              path: RoutePaths.roles,
              builder: (context, state) => const RolesScreen(),
            ),
            GoRoute(
              path: RoutePaths.settings,
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    );
  }

  final Store<AppState> _store;
  final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'rootNavigator');
  final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shellNavigator');
  late final GoRouter router;

  Widget _buildShell(BuildContext context, GoRouterState state, Widget child) {
    return StoreConnector<AppState, _ShellViewModel>(
      converter: (store) => _ShellViewModel(
        userName: store.state.authState.currentUser?.name ?? 'Admin',
        userRole: store.state.authState.currentUser?.role ?? 'Administrator',
      ),
      builder: (context, vm) {
        return AdaptiveScaffold(
          location: state.uri.path,
          destinations: _destinations,
          userName: vm.userName,
          userRole: vm.userRole,
          onToggleTheme: () => StoreProvider.of<AppState>(
            context,
          ).dispatch(ToggleThemeModeAction()),
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
  const _ShellViewModel({required this.userName, required this.userRole});

  final String userName;
  final String userRole;
}
