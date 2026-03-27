import 'package:redux/redux.dart';

import '../core/services/app_dependencies.dart';
import '../modules/auth/state/auth_state.dart';
import '../modules/content_management/state/content_middleware.dart';
import '../modules/course_offerings/state/course_offerings_middleware.dart';
import '../modules/dashboard/state/dashboard_state.dart';
import '../modules/departments/state/departments_state.dart';
import '../modules/enrollments/state/enrollments_middleware.dart';
import '../modules/moderation/state/moderation_state.dart';
import '../modules/notifications/state/notifications_state.dart';
import '../modules/roles_permissions/state/roles_state.dart';
import '../modules/schedule/state/schedule_state.dart';
import '../modules/sections/state/sections_state.dart';
import '../modules/splash/state/bootstrap_state.dart';
import '../modules/staff/state/staff_state.dart';
import '../modules/students/state/students_state.dart';
import '../modules/subjects/state/subjects_state.dart';
import '../modules/uploads/state/uploads_state.dart';
import 'app_reducer.dart';
import 'app_state.dart';

Store<AppState> createAppStore(AppDependencies deps) {
  final store = Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
    middleware: [
      ...createBootstrapMiddleware(deps),
      ...createAuthMiddleware(deps),
      ...createDashboardMiddleware(deps),
      ...createStudentsMiddleware(deps),
      ...createStaffMiddleware(deps),
      ...createDepartmentsMiddleware(deps),
      ...createSectionsMiddleware(deps),
      ...createSubjectsMiddleware(deps),
      ...createCourseOfferingsMiddleware(deps),
      ...createEnrollmentsMiddleware(deps),
      ...createContentMiddleware(deps),
      ...createUploadsMiddleware(deps),
      ...createScheduleMiddleware(deps),
      ...createNotificationsMiddleware(deps),
      ...createModerationMiddleware(deps),
      ...createRolesMiddleware(deps),
    ],
  );
  store.dispatch(BootstrapRequestedAction());
  return store;
}
