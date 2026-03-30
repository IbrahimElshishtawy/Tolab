import '../../../academy_panel/models/academy_models.dart';

class StudentNavigateAction {
  StudentNavigateAction(this.pageKey);

  final String pageKey;
}

class StudentLoadPageAction {
  StudentLoadPageAction(this.pageKey, {this.force = false});

  final String pageKey;
  final bool force;
}

class StudentPageLoadedAction {
  StudentPageLoadedAction(this.pageKey, this.page);

  final String pageKey;
  final RolePageData page;
}

class StudentPageFailedAction {
  StudentPageFailedAction(this.message);

  final String message;
}

class StudentNotificationReceivedAction {
  StudentNotificationReceivedAction(this.notification);

  final AcademyNotificationItem notification;
}

class StudentNotificationReadAction {
  StudentNotificationReadAction(this.notificationId);

  final String notificationId;
}

class StudentCrudRequestedAction {
  StudentCrudRequestedAction({
    required this.pageKey,
    required this.payload,
    this.entityId,
    this.delete = false,
  });

  final String pageKey;
  final JsonMap payload;
  final String? entityId;
  final bool delete;
}
