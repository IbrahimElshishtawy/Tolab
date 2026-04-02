import '../../app_admin/core/routing/route_paths.dart' as admin_routes;
import '../auth/models/auth_role.dart';
import '../auth/state/auth_state.dart';
import '../routing/app_routes.dart';

class AuthGuard {
  const AuthGuard._();

  static final Set<String> _publicRoutes = <String>{
    UnifiedAppRoutes.root,
    UnifiedAppRoutes.launch,
    UnifiedAppRoutes.login,
    UnifiedAppRoutes.forgotPassword,
    UnifiedAppRoutes.inactive,
    UnifiedAppRoutes.unauthorized,
  };

  static final Set<String> _adminRoots = <String>{
    admin_routes.RoutePaths.dashboard,
    admin_routes.RoutePaths.students,
    admin_routes.RoutePaths.staff,
    admin_routes.RoutePaths.departments,
    admin_routes.RoutePaths.sections,
    admin_routes.RoutePaths.subjects,
    admin_routes.RoutePaths.courseOfferings,
    admin_routes.RoutePaths.enrollments,
    admin_routes.RoutePaths.content,
    admin_routes.RoutePaths.schedule,
    admin_routes.RoutePaths.uploads,
    admin_routes.RoutePaths.notifications,
    admin_routes.RoutePaths.moderation,
    admin_routes.RoutePaths.roles,
    admin_routes.RoutePaths.settings,
  };

  static String? redirect(UnifiedAuthState state, String location) {
    if (location == UnifiedAppRoutes.root) {
      return UnifiedAppRoutes.launch;
    }

    if (state.isBootstrapping || state.status == AuthFlowStatus.initial) {
      return location == UnifiedAppRoutes.launch
          ? null
          : UnifiedAppRoutes.launch;
    }

    if (!state.isAuthenticated) {
      if (_publicRoutes.contains(location)) {
        return location == UnifiedAppRoutes.launch
            ? UnifiedAppRoutes.login
            : null;
      }
      return UnifiedAppRoutes.login;
    }

    final user = state.user!;
    if (!user.isActive) {
      return location == UnifiedAppRoutes.inactive
          ? null
          : UnifiedAppRoutes.inactive;
    }

    if (location == UnifiedAppRoutes.launch ||
        location == UnifiedAppRoutes.login ||
        location == UnifiedAppRoutes.forgotPassword ||
        location == UnifiedAppRoutes.inactive) {
      return UnifiedAppRoutes.homeForRole(user.role);
    }

    if (user.role == AuthRole.unknown) {
      return location == UnifiedAppRoutes.unauthorized
          ? null
          : UnifiedAppRoutes.unauthorized;
    }

    if (_isAdminRoute(location)) {
      return user.role == AuthRole.admin ? null : UnifiedAppRoutes.unauthorized;
    }

    if (_isDoctorAssistantRoute(location)) {
      return user.role.isDoctorAssistant
          ? null
          : UnifiedAppRoutes.homeForRole(user.role);
    }

    return null;
  }

  static bool _isAdminRoute(String location) {
    if (_adminRoots.contains(location)) {
      return true;
    }

    return location.startsWith('${admin_routes.RoutePaths.departments}/') ||
        location.startsWith('${admin_routes.RoutePaths.courseOfferings}/') ||
        location == admin_routes.RoutePaths.notificationsHistory;
  }

  static bool _isDoctorAssistantRoute(String location) {
    return location.startsWith('/workspace');
  }
}
