import '../data/reporting_models.dart';

class FetchGradebookAction {
  final int subjectId;
  FetchGradebookAction(this.subjectId);
}

class FetchGradebookSuccessAction {
  final int subjectId;
  final List<GradebookEntry> gradebook;
  FetchGradebookSuccessAction(this.subjectId, this.gradebook);
}

class FetchProgressAction {
  final int subjectId;
  FetchProgressAction(this.subjectId);
}

class FetchProgressSuccessAction {
  final int subjectId;
  final StudentProgress progress;
  FetchProgressSuccessAction(this.subjectId, this.progress);
}
