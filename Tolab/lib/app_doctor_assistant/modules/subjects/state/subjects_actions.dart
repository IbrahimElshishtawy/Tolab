import '../../../core/models/academic_models.dart';

class LoadSubjectsAction {}

class LoadSubjectsSuccessAction {
  LoadSubjectsSuccessAction(this.items);

  final List<SubjectModel> items;
}

class LoadSubjectsFailureAction {
  LoadSubjectsFailureAction(this.message);

  final String message;
}

class LoadSubjectDetailAction {
  LoadSubjectDetailAction(this.subjectId);

  final int subjectId;
}

class LoadSubjectDetailSuccessAction {
  LoadSubjectDetailSuccessAction(this.subject);

  final SubjectModel subject;
}
