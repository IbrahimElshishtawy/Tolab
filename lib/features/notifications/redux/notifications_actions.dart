class FetchNotificationsAction {}
class FetchNotificationsSuccessAction {
  final List<dynamic> notifications;
  FetchNotificationsSuccessAction(this.notifications);
}
class MarkNotificationReadAction {
  final int id;
  MarkNotificationReadAction(this.id);
}
