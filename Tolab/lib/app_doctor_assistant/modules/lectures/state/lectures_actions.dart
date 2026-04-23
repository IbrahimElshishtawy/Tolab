import '../../../core/models/content_models.dart';

class LoadLecturesAction {}

class LoadLecturesSuccessAction {
  LoadLecturesSuccessAction(this.items);

  final List<LectureModel> items;
}

class LoadLecturesFailureAction {
  LoadLecturesFailureAction(this.message);

  final String message;
}

class SaveLectureAction {
  SaveLectureAction(this.payload);

  final Map<String, dynamic> payload;
}

class DeleteLectureAction {
  DeleteLectureAction(this.lectureId);

  final int lectureId;
}

class PublishLectureAction {
  PublishLectureAction(this.lectureId);

  final int lectureId;
}
