import 'package:redux/redux.dart';
import '../../../redux/app_state.dart';
import '../../../config/env.dart';
import '../data/tasks_api.dart';
import '../../../mock/fake_repositories/tasks_fake_repo.dart';
import 'tasks_actions.dart';

List<Middleware<AppState>> createTasksMiddlewares() {
  return [
    TypedMiddleware<AppState, FetchTasksAction>(_fetchTasksMiddleware),
  ];
}

void _fetchTasksMiddleware(Store<AppState> store, FetchTasksAction action, NextDispatcher next) async {
  next(action);

  store.dispatch(FetchTasksStartAction());

  try {
    List<dynamic> tasks;
    if (Env.useMock) {
      final repo = TasksFakeRepo();
      tasks = await repo.getTasks(action.subjectId);
    } else {
      final api = TasksApi();
      final response = await api.getTasks(action.subjectId);
      tasks = response.data;
    }
    store.dispatch(FetchTasksSuccessAction(action.subjectId, tasks.cast()));
  } catch (e) {
    store.dispatch(FetchTasksFailureAction(e.toString()));
  }
}
