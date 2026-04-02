import '../../../core/models/notification_models.dart';
import '../../../core/state/async_state.dart';

class NotificationsState extends AsyncState<List<NotificationModel>> {
  const NotificationsState({
    super.status,
    super.data,
    super.error,
  });
}
