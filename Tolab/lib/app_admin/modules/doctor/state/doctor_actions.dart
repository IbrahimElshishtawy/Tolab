import '../../academy_panel/models/academy_models.dart';

class DoctorNavigateAction {
  DoctorNavigateAction(this.pageKey);

  final String pageKey;
}

class DoctorLoadPageAction {
  DoctorLoadPageAction(this.pageKey, {this.force = false});

  final String pageKey;
  final bool force;
}

class DoctorPageLoadedAction {
  DoctorPageLoadedAction(this.pageKey, this.page);

  final String pageKey;
  final RolePageData page;
}

class DoctorPageFailedAction {
  DoctorPageFailedAction(this.message);

  final String message;
}

class DoctorNotificationReceivedAction {
  DoctorNotificationReceivedAction(this.notification);

  final AcademyNotificationItem notification;
}

class DoctorNotificationReadAction {
  DoctorNotificationReadAction(this.notificationId);

  final String notificationId;
}

class DoctorCrudRequestedAction {
  DoctorCrudRequestedAction({
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

class DoctorUploadRequestedAction {
  DoctorUploadRequestedAction({required this.pageKey, required this.files});

  final String pageKey;
  final List<UploadDraft> files;
}
