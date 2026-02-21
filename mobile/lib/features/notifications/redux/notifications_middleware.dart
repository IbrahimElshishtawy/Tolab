import 'package:redux/redux.dart';
import '../../../redux/app_state.dart';
import '../data/notifications_api.dart';
import '../../../mock/fake_repositories/notifications_fake_repo.dart';
import '../../../config/env.dart';
import 'notifications_actions.dart';

List<Middleware<AppState>> createNotificationsMiddlewares() {
  return [
    TypedMiddleware<AppState, FetchNotificationsAction>(
      _fetchNotifications,
    ).call,
    TypedMiddleware<AppState, MarkNotificationReadAction>(_markRead).call,
  ];
}

void _fetchNotifications(
  Store<AppState> store,
  FetchNotificationsAction action,
  NextDispatcher next,
) async {
  next(action);
  try {
    List<dynamic> notifications;
    if (Env.useMock) {
      final repo = NotificationsFakeRepo();
      notifications = await repo.getNotifications();
    } else {
      final api = NotificationsApi();
      final response = await api.getNotifications();
      notifications = response.data;
    }
    store.dispatch(FetchNotificationsSuccessAction(notifications));
  } catch (e) {
    // handle error
  }
}

void _markRead(
  Store<AppState> store,
  MarkNotificationReadAction action,
  NextDispatcher next,
) async {
  next(action);
  if (!Env.useMock) {
    await NotificationsApi().markRead(action.id);
  }
}
