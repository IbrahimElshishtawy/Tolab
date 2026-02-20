import 'tasks_state.dart';
import 'tasks_actions.dart';

TasksState tasksReducer(TasksState state, dynamic action) {
  if (action is FetchTasksStartAction) {
    return state.copyWith(isLoading: true, error: null);
  }
  if (action is FetchTasksSuccessAction) {
    final newSubjectTasks = Map<int, List<Task>>.from(state.subjectTasks);
    newSubjectTasks[action.subjectId] = action.tasks;
    return state.copyWith(
      subjectTasks: newSubjectTasks,
      isLoading: false,
    );
  }
  if (action is FetchTasksFailureAction) {
    return state.copyWith(
      isLoading: false,
      error: action.error,
    );
  }
  return state;
}
