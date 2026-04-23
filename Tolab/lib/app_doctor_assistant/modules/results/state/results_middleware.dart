import 'package:redux/redux.dart';

import '../../../state/app_state.dart';
import '../repositories/results_repository.dart';
import 'results_actions.dart';

List<Middleware<DoctorAssistantAppState>> createResultsMiddleware(
  ResultsRepository repository,
) {
  return [
    TypedMiddleware<DoctorAssistantAppState, LoadResultsOverviewAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final overview = await repository.fetchOverview();
        store.dispatch(LoadResultsOverviewSuccessAction(overview));
      } catch (error) {
        store.dispatch(LoadResultsOverviewFailureAction(error.toString()));
      }
    }).call,
    TypedMiddleware<DoctorAssistantAppState, LoadSubjectResultsAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final results = await repository.fetchSubjectResults(action.subjectId);
        store.dispatch(LoadSubjectResultsSuccessAction(results));
      } catch (error) {
        store.dispatch(LoadSubjectResultsFailureAction(error.toString()));
      }
    }).call,
    TypedMiddleware<DoctorAssistantAppState, SaveGradesDraftAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      await repository.saveGradesDraft(action.subjectId, action.payload);
      store.dispatch(LoadSubjectResultsAction(action.subjectId));
      store.dispatch(LoadResultsOverviewAction());
    }).call,
    TypedMiddleware<DoctorAssistantAppState, PublishGradesAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      await repository.publishGrades(action.subjectId, action.payload);
      store.dispatch(LoadSubjectResultsAction(action.subjectId));
      store.dispatch(LoadResultsOverviewAction());
    }).call,
  ];
}
