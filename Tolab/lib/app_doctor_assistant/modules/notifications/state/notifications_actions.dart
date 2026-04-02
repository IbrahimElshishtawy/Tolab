import '../../../core/models/notification_models.dart';

class LoadNotificationsAction {}

class LoadNotificationsSuccessAction {
  LoadNotificationsSuccessAction(this.items);

  final List<NotificationModel> items;
}

class LoadNotificationsFailureAction {
  LoadNotificationsFailureAction(this.message);

  final String message;
}

class MarkNotificationReadAction {
  MarkNotificationReadAction(this.notificationId);

  final int notificationId;
}
