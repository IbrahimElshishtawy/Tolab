import '../../academy_panel/models/academy_models.dart';

class AdminNavigateAction {
  AdminNavigateAction(this.pageKey);

  final String pageKey;
}

class AdminLoadPageAction {
  AdminLoadPageAction(this.pageKey, {this.force = false});

  final String pageKey;
  final bool force;
}

class AdminPageLoadedAction {
  AdminPageLoadedAction(this.pageKey, this.page);

  final String pageKey;
  final RolePageData page;
}

class AdminPageFailedAction {
  AdminPageFailedAction(this.message);

  final String message;
}

class AdminNotificationReceivedAction {
  AdminNotificationReceivedAction(this.notification);

  final AcademyNotificationItem notification;
}

class AdminNotificationReadAction {
  AdminNotificationReadAction(this.notificationId);

  final String notificationId;
}

class AdminCrudRequestedAction {
  AdminCrudRequestedAction({
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

class AdminUploadRequestedAction {
  AdminUploadRequestedAction({required this.pageKey, required this.files});

  final String pageKey;
  final List<UploadDraft> files;
}
