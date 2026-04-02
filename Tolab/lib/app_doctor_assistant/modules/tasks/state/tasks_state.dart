import '../../../core/models/content_models.dart';
import '../../../core/state/async_state.dart';

class TasksState extends AsyncState<List<TaskModel>> {
  const TasksState({
    super.status,
    super.data,
    super.error,
  });
}
