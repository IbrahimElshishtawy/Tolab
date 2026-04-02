import '../../../core/models/notification_models.dart';

class LoadScheduleAction {}

class LoadScheduleSuccessAction {
  LoadScheduleSuccessAction(this.items);

  final List<ScheduleEventModel> items;
}

class LoadScheduleFailureAction {
  LoadScheduleFailureAction(this.message);

  final String message;
}
