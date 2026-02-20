import 'package:redux/redux.dart';
import '../../../redux/app_state.dart';
import '../../../config/env.dart';
import '../data/subjects_api.dart';
import '../../../mock/fake_repositories/subjects_fake_repo.dart';
import 'subjects_actions.dart';

List<Middleware<AppState>> createSubjectsMiddlewares() {
  return [
    TypedMiddleware<AppState, FetchSubjectsAction>(_fetchSubjectsMiddleware),
  ];
}

void _fetchSubjectsMiddleware(Store<AppState> store, FetchSubjectsAction action, NextDispatcher next) async {
  next(action);

  store.dispatch(FetchSubjectsStartAction());

  try {
    List<dynamic> subjects;
    if (Env.useMock) {
      final repo = SubjectsFakeRepo();
      subjects = await repo.getSubjects();
    } else {
      final api = SubjectsApi();
      final response = await api.getSubjects();
      subjects = response.data;
    }
    store.dispatch(FetchSubjectsSuccessAction(subjects.cast()));
  } catch (e) {
    store.dispatch(FetchSubjectsFailureAction(e.toString()));
  }
}
