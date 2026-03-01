import 'package:tolab_fci/features/auth/redux/auth_state.dart';
import 'package:tolab_fci/features/subjects/redux/subjects_state.dart';
import 'package:tolab_fci/features/tasks/redux/tasks_state.dart';
import 'package:tolab_fci/features/calendar/redux/calendar_state.dart';
import 'package:tolab_fci/features/community/redux/community_state.dart';
import 'package:tolab_fci/features/notifications/redux/notifications_state.dart';
import 'package:tolab_fci/redux/state/admin_state.dart';
import 'package:tolab_fci/redux/state/ui_state.dart';

class AppState {
  final AuthState authState;
  final SubjectsState subjectsState;
  final TasksState tasksState;
  final CalendarState calendarState;
  final CommunityState communityState;
  final NotificationsState notificationsState;
  final AdminState adminState;
  final UIState uiState;

  AppState({
    required this.authState,
    required this.subjectsState,
    required this.tasksState,
    required this.calendarState,
    required this.communityState,
    required this.notificationsState,
    required this.adminState,
    required this.uiState,
  });

  factory AppState.initial() {
    return AppState(
      authState: AuthState.initial(),
      subjectsState: SubjectsState.initial(),
      tasksState: TasksState.initial(),
      calendarState: CalendarState.initial(),
      communityState: CommunityState.initial(),
      notificationsState: NotificationsState.initial(),
      adminState: AdminState.initial(),
      uiState: UIState.initial(),
    );
  }

  AppState copyWith({
    AuthState? authState,
    SubjectsState? subjectsState,
    TasksState? tasksState,
    CalendarState? calendarState,
    CommunityState? communityState,
    NotificationsState? notificationsState,
    AdminState? adminState,
    UIState? uiState,
  }) {
    return AppState(
      authState: authState ?? this.authState,
      subjectsState: subjectsState ?? this.subjectsState,
      tasksState: tasksState ?? this.tasksState,
      calendarState: calendarState ?? this.calendarState,
      communityState: communityState ?? this.communityState,
      notificationsState: notificationsState ?? this.notificationsState,
      adminState: adminState ?? this.adminState,
      uiState: uiState ?? this.uiState,
    );
  }
}
