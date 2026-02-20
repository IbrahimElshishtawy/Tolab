import '../data/models.dart';

class FetchTasksAction {
  final int subjectId;
  FetchTasksAction(this.subjectId);
}

class FetchTasksStartAction {}

class FetchTasksSuccessAction {
  final int subjectId;
  final List<Task> tasks;
  FetchTasksSuccessAction(this.subjectId, this.tasks);
}

class FetchTasksFailureAction {
  final String error;
  FetchTasksFailureAction(this.error);
}

class SubmitTaskAction {
  final int taskId;
  final String fileUrl;
  SubmitTaskAction(this.taskId, this.fileUrl);
}

class SubmitTaskStartAction {
  final int taskId;
  SubmitTaskStartAction(this.taskId);
}

class SubmitTaskSuccessAction {
  final int taskId;
  final DateTime submittedAt;
  SubmitTaskSuccessAction(this.taskId, this.submittedAt);
}

class SubmitTaskFailureAction {
  final int taskId;
  final String error;
  SubmitTaskFailureAction(this.taskId, this.error);
}
