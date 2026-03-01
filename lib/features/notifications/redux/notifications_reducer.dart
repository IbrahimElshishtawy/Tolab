import 'notifications_state.dart';
import 'notifications_actions.dart';

NotificationsState notificationsReducer(NotificationsState state, dynamic action) {
  if (action is FetchNotificationsSuccessAction) {
    return state.copyWith(notifications: action.notifications);
  }
  return state;
}
