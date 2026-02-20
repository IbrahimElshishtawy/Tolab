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
