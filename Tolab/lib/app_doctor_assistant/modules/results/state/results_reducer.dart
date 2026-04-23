import '../../../core/state/async_state.dart';
import '../models/results_models.dart';
import 'results_actions.dart';
import 'results_state.dart';

ResultsState resultsReducer(ResultsState state, dynamic action) {
  switch (action) {
    case LoadResultsOverviewAction _:
      return state.copyWith(
        overview: const AsyncState<ResultsOverviewModel>(
          status: ViewStatus.loading,
        ),
      );
    case LoadResultsOverviewSuccessAction action:
      return state.copyWith(
        overview: AsyncState<ResultsOverviewModel>(
          status: ViewStatus.success,
          data: action.overview,
        ),
      );
    case LoadResultsOverviewFailureAction action:
      return state.copyWith(
        overview: AsyncState<ResultsOverviewModel>(
          status: ViewStatus.failure,
          error: action.message,
        ),
      );
    case LoadSubjectResultsAction _:
    case SaveGradesDraftAction _:
    case PublishGradesAction _:
      return state.copyWith(
        subject: AsyncState<SubjectResultsModel>(
          status: ViewStatus.loading,
          data: state.subject.data,
        ),
      );
    case LoadSubjectResultsSuccessAction action:
      return state.copyWith(
        subject: AsyncState<SubjectResultsModel>(
          status: ViewStatus.success,
          data: action.results,
        ),
      );
    case LoadSubjectResultsFailureAction action:
      return state.copyWith(
        subject: AsyncState<SubjectResultsModel>(
          status: ViewStatus.failure,
          data: state.subject.data,
          error: action.message,
        ),
      );
    default:
      return state;
  }
}
