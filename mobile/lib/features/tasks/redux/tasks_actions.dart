import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import '../data/tasks_api.dart';
import '../data/models.dart';
import '../../../redux/app_state.dart';

class FetchTasksStartAction {}

class FetchTasksSuccessAction {
  final int subjectId;
  final List<Task> tasks;
  FetchTasksSuccessAction(this.subjectId, this.tasks);
}

class FetchTasksFailureAction {
  final String error;
  FetchTasksFailureAction(this.error);
}

ThunkAction<AppState> fetchTasksAction(int subjectId) {
  return (Store<AppState> store) async {
    store.dispatch(FetchTasksStartAction());
    try {
      final api = TasksApi();
      final response = await api.getTasks(subjectId);
      final List<dynamic> data = response.data;
      final tasks = data.map((json) => Task.fromJson(json)).toList();
      store.dispatch(FetchTasksSuccessAction(subjectId, tasks));
    } catch (e) {
      store.dispatch(FetchTasksFailureAction(e.toString()));
    }
  };
}
