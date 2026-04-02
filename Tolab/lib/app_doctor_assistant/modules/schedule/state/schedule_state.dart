import '../../../core/models/notification_models.dart';
import '../../../core/state/async_state.dart';

class ScheduleState extends AsyncState<List<ScheduleEventModel>> {
  const ScheduleState({
    super.status,
    super.data,
    super.error,
  });
}
