import 'app_state.dart';
import '../modules/auth/state/auth_state.dart';
import '../modules/content_management/state/content_reducer.dart';
import '../modules/course_offerings/state/course_offerings_reducer.dart';
import '../modules/dashboard/state/dashboard_state.dart';
import '../modules/departments/state/departments_state.dart';
import '../modules/enrollments/state/enrollments_reducer.dart';
import '../modules/moderation/state/moderation_state.dart';
import '../modules/notifications/state/notifications_state.dart';
import '../modules/roles_permissions/state/roles_reducer.dart';
import '../modules/schedule/state/schedule_reducer.dart';
import '../modules/sections/state/sections_state.dart';
import '../modules/settings/state/settings_state.dart';
import '../modules/splash/state/bootstrap_state.dart';
import '../modules/staff/state/staff_state.dart';
import '../modules/students/state/students_state.dart';
import '../modules/subjects/state/subjects_state.dart';
import '../modules/uploads/state/uploads_state.dart';

AppState appReducer(AppState state, dynamic action) {
  return AppState(
    bootstrapState: bootstrapReducer(state.bootstrapState, action),
    authState: authReducer(state.authState, action),
    settingsState: settingsReducer(state.settingsState, action),
    dashboardState: dashboardReducer(state.dashboardState, action),
    studentsState: studentsReducer(state.studentsState, action),
    staffState: staffReducer(state.staffState, action),
    departmentsState: departmentsReducer(state.departmentsState, action),
    sectionsState: sectionsReducer(state.sectionsState, action),
    subjectsState: subjectsReducer(state.subjectsState, action),
    courseOfferingsState: courseOfferingsReducer(
      state.courseOfferingsState,
      action,
    ),
    enrollmentsState: enrollmentsReducer(state.enrollmentsState, action),
    contentState: contentReducer(state.contentState, action),
    uploadsState: uploadsReducer(state.uploadsState, action),
    scheduleState: scheduleReducer(state.scheduleState, action),
    notificationsState: notificationsReducer(state.notificationsState, action),
    moderationState: moderationReducer(state.moderationState, action),
    rolesState: rolesReducer(state.rolesState, action),
  );
}
