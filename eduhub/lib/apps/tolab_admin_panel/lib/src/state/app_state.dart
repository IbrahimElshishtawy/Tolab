import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/auth/auth_state.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/dashboard/dashboard_state.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/students/students_state.dart';

class AppState {
  final AuthState auth;
  final DashboardState dashboard;
  final StudentsState students;

  AppState({
    required this.auth,
    required this.dashboard,
    required this.students,
  });

  factory AppState.initial() {
    return AppState(
      auth: AuthState.initial(),
      dashboard: DashboardState.initial(),
      students: StudentsState.initial(),
    );
  }

  AppState copyWith({
    AuthState? auth,
    DashboardState? dashboard,
    StudentsState? students,
  }) {
    return AppState(
      auth: auth ?? this.auth,
      dashboard: dashboard ?? this.dashboard,
      students: students ?? this.students,
    );
  }
}
