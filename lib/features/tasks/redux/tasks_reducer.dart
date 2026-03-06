import 'tasks_state.dart';
import 'tasks_actions.dart';
import '../data/models.dart';

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

  if (action is OperationStartAction) {
    return state.copyWith(isOperating: true, error: null);
  }
  if (action is OperationSuccessAction) {
    return state.copyWith(isOperating: false);
  }
  if (action is OperationFailureAction) {
    return state.copyWith(isOperating: false, error: action.error);
  }

  if (action is FetchSubmissionsSuccessAction) {
    final newTaskSubmissions = Map<int, List<Submission>>.from(state.taskSubmissions);
    newTaskSubmissions[action.taskId] = action.submissions;
    return state.copyWith(
      taskSubmissions: newTaskSubmissions,
      isLoading: false,
    );
  }

  return state;
}
