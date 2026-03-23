import '../data/models.dart';

class FetchSubjectsAction {}
class FetchSubjectsStartAction {}
class FetchSubjectsSuccessAction {
  final List<Subject> subjects;
  FetchSubjectsSuccessAction(this.subjects);
}
class FetchSubjectsFailureAction {
  final String error;
  FetchSubjectsFailureAction(this.error);
}

class FetchSubjectContentAction {
  final int subjectId;
  FetchSubjectContentAction(this.subjectId);
}

class FetchSubjectContentSuccessAction {
  final int subjectId;
  final List<Lecture> lectures;
  final List<Section> sections;
  final List<Quiz> quizzes;
  final List<Summary> summaries;
  FetchSubjectContentSuccessAction({
    required this.subjectId,
    required this.lectures,
    required this.sections,
    required this.quizzes,
    required this.summaries,
  });
}

class AddSummaryAction {
  final int subjectId;
  final Summary summary;
  AddSummaryAction(this.subjectId, this.summary);
}
