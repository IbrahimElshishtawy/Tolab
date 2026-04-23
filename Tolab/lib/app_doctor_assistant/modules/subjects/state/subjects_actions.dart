import '../../../core/models/academic_models.dart';
import '../models/subject_workspace_models.dart';

class LoadSubjectsAction {}

class LoadSubjectsSuccessAction {
  LoadSubjectsSuccessAction(this.items);

  final List<SubjectModel> items;
}

class LoadSubjectsFailureAction {
  LoadSubjectsFailureAction(this.message);

  final String message;
}

class LoadSubjectWorkspaceAction {
  LoadSubjectWorkspaceAction(this.subjectId);

  final int subjectId;
}

class LoadSubjectWorkspaceSuccessAction {
  LoadSubjectWorkspaceSuccessAction(this.workspace);

  final SubjectWorkspaceModel workspace;
}

class LoadSubjectWorkspaceFailureAction {
  LoadSubjectWorkspaceFailureAction(this.message);

  final String message;
}
