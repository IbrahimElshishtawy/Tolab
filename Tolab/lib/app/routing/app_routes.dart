import '../../app_admin/core/routing/route_paths.dart' as admin_routes;
import '../../app_doctor_assistant/core/navigation/app_routes.dart'
    as staff_routes;
import '../auth/models/auth_role.dart';

class UnifiedAppRoutes {
  const UnifiedAppRoutes._();

  static const root = '/';
  static const launch = '/launch';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const inactive = '/inactive';
  static const unauthorized = '/unauthorized';

  static String homeForRole(AuthRole role) {
    return switch (role) {
      AuthRole.admin => admin_routes.RoutePaths.dashboard,
      AuthRole.doctor || AuthRole.assistant => staff_routes.AppRoutes.dashboard,
      AuthRole.unknown => unauthorized,
    };
  }
}
