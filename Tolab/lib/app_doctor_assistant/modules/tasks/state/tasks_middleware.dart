import 'package:redux/redux.dart';

import '../../../state/app_state.dart';
import '../repositories/tasks_repository.dart';
import 'tasks_actions.dart';

List<Middleware<DoctorAssistantAppState>> createTasksMiddleware(
  TasksRepository repository,
) {
  return [
    TypedMiddleware<DoctorAssistantAppState, LoadTasksAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final items = await repository.fetchTasks();
        store.dispatch(LoadTasksSuccessAction(items));
      } catch (error) {
        store.dispatch(LoadTasksFailureAction(error.toString()));
      }
    }).call,
    TypedMiddleware<DoctorAssistantAppState, SaveTaskAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      await repository.saveTask(action.payload);
      store.dispatch(LoadTasksAction());
    }).call,
  ];
}
