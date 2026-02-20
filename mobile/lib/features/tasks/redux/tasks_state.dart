import '../data/models.dart';

class TasksState {
  final Map<int, List<Task>> subjectTasks; // subjectId -> tasks
  final bool isLoading;
  final String? error;

  TasksState({
    required this.subjectTasks,
    required this.isLoading,
    this.error,
  });

  factory TasksState.initial() => TasksState(
    subjectTasks: {},
    isLoading: false,
  );

  TasksState copyWith({
    Map<int, List<Task>>? subjectTasks,
    bool? isLoading,
    String? error,
  }) {
    return TasksState(
      subjectTasks: subjectTasks ?? this.subjectTasks,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
