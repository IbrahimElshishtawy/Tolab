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
