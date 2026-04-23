import '../models/results_models.dart';

class LoadResultsOverviewAction {}

class LoadResultsOverviewSuccessAction {
  LoadResultsOverviewSuccessAction(this.overview);

  final ResultsOverviewModel overview;
}

class LoadResultsOverviewFailureAction {
  LoadResultsOverviewFailureAction(this.message);

  final String message;
}

class LoadSubjectResultsAction {
  LoadSubjectResultsAction(this.subjectId);

  final int subjectId;
}

class LoadSubjectResultsSuccessAction {
  LoadSubjectResultsSuccessAction(this.results);

  final SubjectResultsModel results;
}

class LoadSubjectResultsFailureAction {
  LoadSubjectResultsFailureAction(this.message);

  final String message;
}

class SaveGradesDraftAction {
  SaveGradesDraftAction({
    required this.subjectId,
    required this.payload,
  });

  final int subjectId;
  final Map<String, dynamic> payload;
}

class PublishGradesAction {
  PublishGradesAction({
    required this.subjectId,
    required this.payload,
  });

  final int subjectId;
  final Map<String, dynamic> payload;
}
