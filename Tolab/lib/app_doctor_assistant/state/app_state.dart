import '../modules/admin/state/admin_state.dart';
import '../modules/auth/state/auth_state.dart';
import '../modules/auth/state/session_state.dart';
import '../modules/bootstrap/state/bootstrap_state.dart';
import '../modules/dashboard/state/dashboard_state.dart';
import '../modules/groups/state/groups_state.dart';
import '../modules/lectures/state/lectures_state.dart';
import '../modules/notifications/state/notifications_state.dart';
import '../modules/quizzes/state/quizzes_state.dart';
import '../modules/results/state/results_state.dart';
import '../modules/schedule/state/schedule_state.dart';
import '../modules/section_content/state/section_content_state.dart';
import '../modules/settings/state/settings_state.dart';
import '../modules/staff/state/staff_state.dart';
import '../modules/subjects/state/subjects_state.dart';
import '../modules/tasks/state/tasks_state.dart';
import '../modules/uploads/state/uploads_state.dart';

class DoctorAssistantAppState {
  const DoctorAssistantAppState({
    this.bootstrapState = const BootstrapState(),
    this.authState = const AuthState(),
    this.sessionState = const SessionState(),
    this.dashboardState = const DashboardState(),
    this.staffState = const StaffState(),
    this.subjectsState = const SubjectsState(),
    this.groupsState = const GroupsState(),
    this.lecturesState = const LecturesState(),
    this.resultsState = const ResultsState(),
    this.sectionContentState = const SectionContentState(),
    this.quizzesState = const QuizzesState(),
    this.tasksState = const TasksState(),
    this.scheduleState = const ScheduleState(),
    this.notificationsState = const NotificationsState(),
    this.uploadsState = const UploadsState(),
    this.settingsState = const SettingsState(),
    this.adminState = const AdminState(),
  });

  final BootstrapState bootstrapState;
  final AuthState authState;
  final SessionState sessionState;
  final DashboardState dashboardState;
  final StaffState staffState;
  final SubjectsState subjectsState;
  final GroupsState groupsState;
  final LecturesState lecturesState;
  final ResultsState resultsState;
  final SectionContentState sectionContentState;
  final QuizzesState quizzesState;
  final TasksState tasksState;
  final ScheduleState scheduleState;
  final NotificationsState notificationsState;
  final UploadsState uploadsState;
  final SettingsState settingsState;
  final AdminState adminState;

  DoctorAssistantAppState copyWith({
    BootstrapState? bootstrapState,
    AuthState? authState,
    SessionState? sessionState,
    DashboardState? dashboardState,
    StaffState? staffState,
    SubjectsState? subjectsState,
    GroupsState? groupsState,
    LecturesState? lecturesState,
    ResultsState? resultsState,
    SectionContentState? sectionContentState,
    QuizzesState? quizzesState,
    TasksState? tasksState,
    ScheduleState? scheduleState,
    NotificationsState? notificationsState,
    UploadsState? uploadsState,
    SettingsState? settingsState,
    AdminState? adminState,
  }) {
    return DoctorAssistantAppState(
      bootstrapState: bootstrapState ?? this.bootstrapState,
      authState: authState ?? this.authState,
      sessionState: sessionState ?? this.sessionState,
      dashboardState: dashboardState ?? this.dashboardState,
      staffState: staffState ?? this.staffState,
      subjectsState: subjectsState ?? this.subjectsState,
      groupsState: groupsState ?? this.groupsState,
      lecturesState: lecturesState ?? this.lecturesState,
      resultsState: resultsState ?? this.resultsState,
      sectionContentState: sectionContentState ?? this.sectionContentState,
      quizzesState: quizzesState ?? this.quizzesState,
      tasksState: tasksState ?? this.tasksState,
      scheduleState: scheduleState ?? this.scheduleState,
      notificationsState: notificationsState ?? this.notificationsState,
      uploadsState: uploadsState ?? this.uploadsState,
      settingsState: settingsState ?? this.settingsState,
      adminState: adminState ?? this.adminState,
    );
  }
}
