import '../models/group_models.dart';

class LoadSubjectGroupAction {
  LoadSubjectGroupAction(this.subjectId);

  final int subjectId;
}

class LoadSubjectGroupSuccessAction {
  LoadSubjectGroupSuccessAction(this.group);

  final SubjectGroupModel group;
}

class LoadSubjectGroupFailureAction {
  LoadSubjectGroupFailureAction(this.message);

  final String message;
}

class SaveGroupPostAction {
  SaveGroupPostAction({
    required this.subjectId,
    required this.payload,
  });

  final int subjectId;
  final Map<String, dynamic> payload;
}

class DeleteGroupPostAction {
  DeleteGroupPostAction({
    required this.subjectId,
    required this.postId,
  });

  final int subjectId;
  final int postId;
}

class TogglePinnedPostAction {
  TogglePinnedPostAction({
    required this.subjectId,
    required this.postId,
  });

  final int subjectId;
  final int postId;
}
