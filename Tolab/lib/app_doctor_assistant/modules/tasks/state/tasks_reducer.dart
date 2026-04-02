import '../../../core/state/async_state.dart';
import 'tasks_actions.dart';
import 'tasks_state.dart';

TasksState tasksReducer(TasksState state, dynamic action) {
  switch (action.runtimeType) {
    case LoadTasksAction:
    case SaveTaskAction:
      return TasksState(status: ViewStatus.loading, data: state.data);
    case LoadTasksSuccessAction:
      return TasksState(
        status: ViewStatus.success,
        data: (action as LoadTasksSuccessAction).items,
      );
    case LoadTasksFailureAction:
      return TasksState(
        status: ViewStatus.failure,
        data: state.data,
        error: (action as LoadTasksFailureAction).message,
      );
    default:
      return state;
  }
}
