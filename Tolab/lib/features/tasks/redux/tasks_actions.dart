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

// Educator Actions
class CreateTaskAction {
  final int subjectId;
  final Task task;
  CreateTaskAction(this.subjectId, this.task);
}

class UpdateTaskAction {
  final Task task;
  UpdateTaskAction(this.task);
}

class DeleteTaskAction {
  final int subjectId;
  final int taskId;
  DeleteTaskAction(this.subjectId, this.taskId);
}

class OperationStartAction {}
class OperationSuccessAction {}
class OperationFailureAction {
  final String error;
  OperationFailureAction(this.error);
}

class FetchSubmissionsAction {
  final int taskId;
  FetchSubmissionsAction(this.taskId);
}

class FetchSubmissionsSuccessAction {
  final int taskId;
  final List<Submission> submissions;
  FetchSubmissionsSuccessAction(this.taskId, this.submissions);
}

class GradeSubmissionAction {
  final int taskId;
  final int submissionId;
  final String grade;
  GradeSubmissionAction(this.taskId, this.submissionId, this.grade);
}
