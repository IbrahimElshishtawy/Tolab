import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/auth/auth_state.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/dashboard/dashboard_state.dart';

import 'students/students_state.dart';
import 'doctors/doctors_state.dart';
import 'assistants/assistants_state.dart';
import 'academic_structure/structure_state.dart';
import 'permissions/permissions_state.dart';

class AppState {
  final AuthState auth;
  final StudentsState students;
  final DoctorsState doctors;
  final DashboardState dashboard;
  final AssistantsState assistants;
  final AcademicStructureState structure;
  final PermissionsState permissions;

  AppState({
    required this.students,
    required this.doctors,
    required this.assistants,
    required this.structure,
    required this.permissions,
    required this.dashboard,
    required this.auth,
  });

  factory AppState.initial() => AppState(
    students: StudentsState.initial(),
    doctors: DoctorsState.initial(),
    assistants: AssistantsState.initial(),
    structure: AcademicStructureState.initial(),
    permissions: PermissionsState.initial(),
    dashboard: DashboardState.initial(),
    auth: AuthState.initial(),
  );
}
