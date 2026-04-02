// ignore_for_file: type_literal_in_constant_pattern

import '../../../core/state/async_state.dart';
import 'notifications_actions.dart';
import 'notifications_state.dart';

NotificationsState notificationsReducer(
  NotificationsState state,
  dynamic action,
) {
  switch (action.runtimeType) {
    case LoadNotificationsAction:
    case MarkNotificationReadAction:
      return NotificationsState(status: ViewStatus.loading, data: state.data);
    case LoadNotificationsSuccessAction:
      return NotificationsState(
        status: ViewStatus.success,
        data: (action as LoadNotificationsSuccessAction).items,
      );
    case LoadNotificationsFailureAction:
      return NotificationsState(
        status: ViewStatus.failure,
        data: state.data,
        error: (action as LoadNotificationsFailureAction).message,
      );
    default:
      return state;
  }
}
