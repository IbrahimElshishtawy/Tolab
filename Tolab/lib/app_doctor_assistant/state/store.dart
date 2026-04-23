import 'package:redux/redux.dart';

import '../core/services/app_dependencies.dart';
import '../modules/admin/state/admin_middleware.dart';
import '../modules/admin/state/admin_reducer.dart';
import '../modules/auth/state/auth_middleware.dart';
import '../modules/auth/state/auth_reducer.dart';
import '../modules/auth/state/session_reducer.dart';
import '../modules/bootstrap/state/bootstrap_middleware.dart';
import '../modules/bootstrap/state/bootstrap_reducer.dart';
import '../modules/dashboard/state/dashboard_middleware.dart';
import '../modules/dashboard/state/dashboard_reducer.dart';
import '../modules/groups/state/groups_middleware.dart';
import '../modules/groups/state/groups_reducer.dart';
import '../modules/lectures/state/lectures_middleware.dart';
import '../modules/lectures/state/lectures_reducer.dart';
import '../modules/notifications/state/notifications_middleware.dart';
import '../modules/notifications/state/notifications_reducer.dart';
import '../modules/quizzes/state/quizzes_middleware.dart';
import '../modules/quizzes/state/quizzes_reducer.dart';
import '../modules/results/state/results_middleware.dart';
import '../modules/results/state/results_reducer.dart';
import '../modules/schedule/state/schedule_middleware.dart';
import '../modules/schedule/state/schedule_reducer.dart';
import '../modules/section_content/state/section_content_middleware.dart';
import '../modules/section_content/state/section_content_reducer.dart';
import '../modules/settings/state/settings_middleware.dart';
import '../modules/settings/state/settings_reducer.dart';
import '../modules/staff/state/staff_middleware.dart';
import '../modules/staff/state/staff_reducer.dart';
import '../modules/subjects/state/subjects_middleware.dart';
import '../modules/subjects/state/subjects_reducer.dart';
import '../modules/tasks/state/tasks_middleware.dart';
import '../modules/tasks/state/tasks_reducer.dart';
import '../modules/uploads/state/uploads_middleware.dart';
import '../modules/uploads/state/uploads_reducer.dart';
import 'app_state.dart';

Store<DoctorAssistantAppState> createDoctorAssistantStore(
  AppDependencies dependencies,
) {
  return Store<DoctorAssistantAppState>(
    _reducer,
    initialState: const DoctorAssistantAppState(),
    middleware: [
      ...createBootstrapMiddleware(dependencies.authRepository),
      ...createAuthMiddleware(dependencies.authRepository),
      ...createDashboardMiddleware(dependencies.dashboardRepository),
      ...createStaffMiddleware(dependencies.staffRepository),
      ...createSubjectsMiddleware(dependencies.subjectsRepository),
      ...createGroupsMiddleware(dependencies.groupsRepository),
      ...createLecturesMiddleware(dependencies.lecturesRepository),
      ...createResultsMiddleware(dependencies.resultsRepository),
      ...createSectionContentMiddleware(dependencies.sectionContentRepository),
      ...createQuizzesMiddleware(dependencies.quizzesRepository),
      ...createTasksMiddleware(dependencies.tasksRepository),
      ...createScheduleMiddleware(dependencies.scheduleRepository),
      ...createNotificationsMiddleware(dependencies.notificationsRepository),
      ...createUploadsMiddleware(dependencies.uploadsRepository),
      ...createSettingsMiddleware(dependencies.settingsRepository),
      ...createAdminMiddleware(dependencies.adminRepository),
    ],
  );
}

DoctorAssistantAppState _reducer(
  DoctorAssistantAppState state,
  dynamic action,
) {
  return state.copyWith(
    bootstrapState: bootstrapReducer(state.bootstrapState, action),
    authState: authReducer(state.authState, action),
    sessionState: sessionReducer(state.sessionState, action),
    dashboardState: dashboardReducer(state.dashboardState, action),
    staffState: staffReducer(state.staffState, action),
    subjectsState: subjectsReducer(state.subjectsState, action),
    groupsState: groupsReducer(state.groupsState, action),
    lecturesState: lecturesReducer(state.lecturesState, action),
    resultsState: resultsReducer(state.resultsState, action),
    sectionContentState: sectionContentReducer(state.sectionContentState, action),
    quizzesState: quizzesReducer(state.quizzesState, action),
    tasksState: tasksReducer(state.tasksState, action),
    scheduleState: scheduleReducer(state.scheduleState, action),
    notificationsState: notificationsReducer(state.notificationsState, action),
    uploadsState: uploadsReducer(state.uploadsState, action),
    settingsState: settingsReducer(state.settingsState, action),
    adminState: adminReducer(state.adminState, action),
  );
}
