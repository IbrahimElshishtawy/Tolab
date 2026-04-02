import '../../../core/models/content_models.dart';

class LoadTasksAction {}

class LoadTasksSuccessAction {
  LoadTasksSuccessAction(this.items);

  final List<TaskModel> items;
}

class LoadTasksFailureAction {
  LoadTasksFailureAction(this.message);

  final String message;
}

class SaveTaskAction {
  SaveTaskAction(this.payload);

  final Map<String, dynamic> payload;
}
