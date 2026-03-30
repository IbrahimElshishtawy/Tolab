import '../modules/auth/state/auth_state.dart';
import '../modules/content_management/state/content_state.dart';
import '../modules/course_offerings/state/course_offerings_state.dart';
import '../modules/dashboard/state/dashboard_state.dart';
import '../modules/departments/state/departments_state.dart';
import '../modules/enrollments/state/enrollments_state.dart';
import '../modules/moderation/state/moderation_state.dart';
import '../modules/notifications/state/notifications_state.dart';
import '../modules/roles_permissions/state/roles_state.dart';
import '../modules/schedule/state/schedule_state.dart';
import '../modules/sections/state/sections_state.dart';
import '../modules/settings/state/settings_state.dart';
import '../modules/splash/state/bootstrap_state.dart';
import '../modules/staff/state/staff_state.dart';
import '../modules/students/state/students_state.dart';
import '../modules/subjects/state/subjects_state.dart';
import '../modules/uploads/state/uploads_state.dart';

class AppState {
  const AppState({
    required this.bootstrapState,
    required this.authState,
    required this.settingsState,
    required this.dashboardState,
    required this.studentsState,
    required this.staffState,
    required this.departmentsState,
    required this.sectionsState,
    required this.subjectsState,
    required this.courseOfferingsState,
    required this.enrollmentsState,
    required this.contentState,
    required this.uploadsState,
    required this.scheduleState,
    required this.notificationsState,
    required this.moderationState,
    required this.rolesState,
  });

  final BootstrapState bootstrapState;
  final AuthState authState;
  final SettingsState settingsState;
  final DashboardState dashboardState;
  final StudentsState studentsState;
  final StaffState staffState;
  final DepartmentsState departmentsState;
  final SectionsState sectionsState;
  final SubjectsState subjectsState;
  final CourseOfferingsState courseOfferingsState;
  final EnrollmentsState enrollmentsState;
  final ContentState contentState;
  final UploadsState uploadsState;
  final ScheduleState scheduleState;
  final NotificationsState notificationsState;
  final ModerationState moderationState;
  final RolesState rolesState;

  factory AppState.initial() {
    return AppState(
      bootstrapState: BootstrapState(),
      authState: AuthState(),
      settingsState: SettingsState(),
      dashboardState: DashboardState(),
      studentsState: initialStudentsState,
      staffState: initialStaffState,
      departmentsState: initialDepartmentsState,
      sectionsState: initialSectionsState,
      subjectsState: initialSubjectsState,
      courseOfferingsState: initialCourseOfferingsState,
      enrollmentsState: initialEnrollmentsState,
      contentState: initialContentState,
      uploadsState: initialUploadsState,
      scheduleState: initialScheduleState,
      notificationsState: initialNotificationsState,
      moderationState: initialModerationState,
      rolesState: initialRolesState,
    );
  }
}
