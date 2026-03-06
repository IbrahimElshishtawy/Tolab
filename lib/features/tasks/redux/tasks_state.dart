import '../data/models.dart';

class TasksState {
  final Map<int, List<Task>> subjectTasks; // subjectId -> tasks
  final Map<int, List<Submission>> taskSubmissions; // taskId -> submissions
  final bool isLoading;
  final bool isOperating; // for create/update/delete
  final String? error;

  TasksState({
    required this.subjectTasks,
    required this.taskSubmissions,
    required this.isLoading,
    this.isOperating = false,
    this.error,
  });

  factory TasksState.initial() => TasksState(
    subjectTasks: {},
    taskSubmissions: {},
    isLoading: false,
  );

  TasksState copyWith({
    Map<int, List<Task>>? subjectTasks,
    Map<int, List<Submission>>? taskSubmissions,
    bool? isLoading,
    bool? isOperating,
    String? error,
  }) {
    return TasksState(
      subjectTasks: subjectTasks ?? this.subjectTasks,
      taskSubmissions: taskSubmissions ?? this.taskSubmissions,
      isLoading: isLoading ?? this.isLoading,
      isOperating: isOperating ?? this.isOperating,
      error: error ?? this.error,
    );
  }
}
