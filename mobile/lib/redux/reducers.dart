import 'app_state.dart';
import 'package:tolab_fci/features/auth/redux/auth_reducer.dart';
import 'package:tolab_fci/features/subjects/redux/subjects_reducer.dart';
import 'package:tolab_fci/features/tasks/redux/tasks_reducer.dart';

AppState appReducer(AppState state, dynamic action) {
  return AppState(
    authState: authReducer(state.authState, action),
    subjectsState: subjectsReducer(state.subjectsState, action),
    tasksState: tasksReducer(state.tasksState, action),
    calendarState: state.calendarState, // Placeholder
    communityState: state.communityState, // Placeholder
    notificationsState: state.notificationsState, // Placeholder
  );
}
