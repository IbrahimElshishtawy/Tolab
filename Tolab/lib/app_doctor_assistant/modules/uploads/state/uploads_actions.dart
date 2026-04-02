import '../../../core/models/notification_models.dart';

class LoadUploadsAction {}

class LoadUploadsSuccessAction {
  LoadUploadsSuccessAction(this.items);

  final List<UploadModel> items;
}

class LoadUploadsFailureAction {
  LoadUploadsFailureAction(this.message);

  final String message;
}

class UploadProgressChangedAction {
  UploadProgressChangedAction(this.progress);

  final double progress;
}
