import '../data/models.dart';

class TaskSubmissionStatus {
  final bool isSubmitted;
  final DateTime? submittedAt;
  final bool isUploading;
  final String? error;

  TaskSubmissionStatus({
    this.isSubmitted = false,
    this.submittedAt,
    this.isUploading = false,
    this.error,
  });

  TaskSubmissionStatus copyWith({
    bool? isSubmitted,
    DateTime? submittedAt,
    bool? isUploading,
    String? error,
  }) {
    return TaskSubmissionStatus(
      isSubmitted: isSubmitted ?? this.isSubmitted,
      submittedAt: submittedAt ?? this.submittedAt,
      isUploading: isUploading ?? this.isUploading,
      error: error ?? this.error,
    );
  }
}

class TasksState {
  final Map<int, List<Task>> subjectTasks; // subjectId -> tasks
  final Map<int, TaskSubmissionStatus> submissions; // taskId -> status
  final bool isLoading;
  final String? error;

  TasksState({
    required this.subjectTasks,
    required this.submissions,
    required this.isLoading,
    this.error,
  });

  factory TasksState.initial() => TasksState(
    subjectTasks: {},
    submissions: {},
    isLoading: false,
  );

  TasksState copyWith({
    Map<int, List<Task>>? subjectTasks,
    Map<int, TaskSubmissionStatus>? submissions,
    bool? isLoading,
    String? error,
  }) {
    return TasksState(
      subjectTasks: subjectTasks ?? this.subjectTasks,
      submissions: submissions ?? this.submissions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
