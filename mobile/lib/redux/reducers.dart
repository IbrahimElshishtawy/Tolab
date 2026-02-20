import 'app_state.dart';
import 'package:tolab_fci/features/auth/redux/auth_reducer.dart';
import 'package:tolab_fci/features/subjects/redux/subjects_reducer.dart';
import 'package:tolab_fci/features/tasks/redux/tasks_reducer.dart';
import 'package:tolab_fci/features/community/redux/community_reducer.dart';
import 'package:tolab_fci/features/calendar/redux/calendar_reducer.dart';

AppState appReducer(AppState state, dynamic action) {
  return AppState(
    authState: authReducer(state.authState, action),
    subjectsState: subjectsReducer(state.subjectsState, action),
    tasksState: tasksReducer(state.tasksState, action),
    calendarState: calendarReducer(state.calendarState, action),
    communityState: communityReducer(state.communityState, action),
    notificationsState: state.notificationsState, // Placeholder
  );
}
