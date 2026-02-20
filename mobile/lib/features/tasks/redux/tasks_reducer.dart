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

  if (action is SubmitTaskStartAction) {
    final newSubmissions = Map<int, TaskSubmissionStatus>.from(state.submissions);
    newSubmissions[action.taskId] = (newSubmissions[action.taskId] ?? TaskSubmissionStatus()).copyWith(
      isUploading: true,
      error: null,
    );
    return state.copyWith(submissions: newSubmissions);
  }

  if (action is SubmitTaskSuccessAction) {
    final newSubmissions = Map<int, TaskSubmissionStatus>.from(state.submissions);
    newSubmissions[action.taskId] = (newSubmissions[action.taskId] ?? TaskSubmissionStatus()).copyWith(
      isUploading: false,
      isSubmitted: true,
      submittedAt: action.submittedAt,
    );
    return state.copyWith(submissions: newSubmissions);
  }

  if (action is SubmitTaskFailureAction) {
    final newSubmissions = Map<int, TaskSubmissionStatus>.from(state.submissions);
    newSubmissions[action.taskId] = (newSubmissions[action.taskId] ?? TaskSubmissionStatus()).copyWith(
      isUploading: false,
      error: action.error,
    );
    return state.copyWith(submissions: newSubmissions);
  }

  return state;
}
