import '../../../core/state/async_state.dart';
import '../models/results_models.dart';

class ResultsState {
  const ResultsState({
    this.overview = const AsyncState<ResultsOverviewModel>(),
    this.subject = const AsyncState<SubjectResultsModel>(),
  });

  final AsyncState<ResultsOverviewModel> overview;
  final AsyncState<SubjectResultsModel> subject;

  ResultsState copyWith({
    AsyncState<ResultsOverviewModel>? overview,
    AsyncState<SubjectResultsModel>? subject,
  }) {
    return ResultsState(
      overview: overview ?? this.overview,
      subject: subject ?? this.subject,
    );
  }
}
