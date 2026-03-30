import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/app_dependencies.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/models/notification_models.dart';
import '../../../state/app_state.dart';
import '../../auth/state/auth_state.dart';

class NotificationsState {
  const NotificationsState({
    this.items = const <AdminNotification>[],
    this.status = LoadStatus.initial,
    this.errorMessage,
    this.connectionStatus = NotificationRealtimeStatus.idle,
    this.activeToast,
    this.toastQueue = const <AdminNotification>[],
    this.isBroadcasting = false,
    this.lastUpdatedAt,
  });

  final List<AdminNotification> items;
  final LoadStatus status;
  final String? errorMessage;
  final NotificationRealtimeStatus connectionStatus;
  final AdminNotification? activeToast;
  final List<AdminNotification> toastQueue;
  final bool isBroadcasting;
  final DateTime? lastUpdatedAt;

  int get unreadCount => items.where((item) => !item.isRead).length;

  Map<AdminNotificationCategory, int> get unreadByCategory => {
    for (final category in AdminNotificationCategory.values)
      category: items
          .where((item) => item.category == category && !item.isRead)
          .length,
  };

  NotificationsState copyWith({
    List<AdminNotification>? items,
    LoadStatus? status,
    String? errorMessage,
    NotificationRealtimeStatus? connectionStatus,
    AdminNotification? activeToast,
    List<AdminNotification>? toastQueue,
    bool? isBroadcasting,
    DateTime? lastUpdatedAt,
    bool clearError = false,
    bool clearActiveToast = false,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      activeToast: clearActiveToast ? null : activeToast ?? this.activeToast,
      toastQueue: toastQueue ?? this.toastQueue,
      isBroadcasting: isBroadcasting ?? this.isBroadcasting,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}

const NotificationsState initialNotificationsState = NotificationsState();

class LoadNotificationsAction {
  const LoadNotificationsAction({this.silent = false});

  final bool silent;
}

class NotificationsLoadedAction {
  const NotificationsLoadedAction(this.items, {this.silent = false});

  final List<AdminNotification> items;
  final bool silent;
}

class NotificationsFailedAction {
  const NotificationsFailedAction(this.message);

  final String message;
}

class StartNotificationsRealtimeAction {
  const StartNotificationsRealtimeAction();
}

class StopNotificationsRealtimeAction {
  const StopNotificationsRealtimeAction();
}

class NotificationsConnectionChangedAction {
  const NotificationsConnectionChangedAction(this.status);

  final NotificationRealtimeStatus status;
}

class IncomingNotificationAction {
  const IncomingNotificationAction(
    this.notification, {
    this.showToast = true,
    this.showLocalAlert = true,
  });

  final AdminNotification notification;
  final bool showToast;
  final bool showLocalAlert;
}

class MarkNotificationReadRequestedAction {
  const MarkNotificationReadRequestedAction(this.notificationId);

  final String notificationId;
}

class NotificationMarkedReadAction {
  const NotificationMarkedReadAction(this.notificationId);

  final String notificationId;
}

class MarkAllNotificationsReadRequestedAction {
  const MarkAllNotificationsReadRequestedAction();
}

class NotificationToastDismissedAction {
  const NotificationToastDismissedAction();
}

class NotificationBroadcastRequestedAction {
  const NotificationBroadcastRequestedAction({
    required this.title,
    required this.body,
    required this.category,
    this.refType,
    this.refId,
    this.onSuccess,
    this.onError,
  });

  final String title;
  final String body;
  final AdminNotificationCategory category;
  final String? refType;
  final String? refId;
  final VoidCallback? onSuccess;
  final void Function(String message)? onError;
}

class NotificationBroadcastFinishedAction {
  const NotificationBroadcastFinishedAction();
}

class NotificationsSessionClearedAction {
  const NotificationsSessionClearedAction();
}

NotificationsState notificationsReducer(
  NotificationsState state,
  dynamic action,
) {
  switch (action) {
    case LoadNotificationsAction():
      return action.silent
          ? state.copyWith(clearError: true)
          : state.copyWith(status: LoadStatus.loading, clearError: true);
    case NotificationsLoadedAction():
      return state.copyWith(
        status: LoadStatus.success,
        items: _sortNotifications(action.items),
        lastUpdatedAt: DateTime.now(),
        clearError: true,
      );
    case NotificationsFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    case NotificationsConnectionChangedAction():
      return state.copyWith(connectionStatus: action.status);
    case IncomingNotificationAction():
      final nextItems = _upsertNotification(state.items, action.notification);
      if (!action.showToast) {
        return state.copyWith(
          items: nextItems,
          lastUpdatedAt: DateTime.now(),
          status: LoadStatus.success,
        );
      }
      if (state.activeToast == null) {
        return state.copyWith(
          items: nextItems,
          activeToast: action.notification,
          lastUpdatedAt: DateTime.now(),
          status: LoadStatus.success,
        );
      }
      return state.copyWith(
        items: nextItems,
        toastQueue: [...state.toastQueue, action.notification],
        lastUpdatedAt: DateTime.now(),
        status: LoadStatus.success,
      );
    case NotificationMarkedReadAction():
      final nextItems = _sortNotifications([
        for (final item in state.items)
          if (item.id == action.notificationId) item.markRead() else item,
      ]);
      final nextActiveToast = state.activeToast?.id == action.notificationId
          ? state.activeToast?.markRead()
          : state.activeToast;
      final nextQueue = [
        for (final item in state.toastQueue)
          if (item.id == action.notificationId) item.markRead() else item,
      ];
      return state.copyWith(
        items: nextItems,
        activeToast: nextActiveToast,
        toastQueue: nextQueue,
      );
    case NotificationToastDismissedAction():
      if (state.activeToast == null && state.toastQueue.isEmpty) {
        return state;
      }
      final queue = [...state.toastQueue];
      final nextActive = queue.isEmpty ? null : queue.removeAt(0);
      return state.copyWith(
        activeToast: nextActive,
        toastQueue: queue,
        clearActiveToast: nextActive == null,
      );
    case NotificationBroadcastRequestedAction():
      return state.copyWith(isBroadcasting: true, clearError: true);
    case NotificationBroadcastFinishedAction():
      return state.copyWith(isBroadcasting: false);
    case NotificationsSessionClearedAction():
      return initialNotificationsState;
    default:
      return state;
  }
}

List<Middleware<AppState>> createNotificationsMiddleware(AppDependencies deps) {
  StreamSubscription<AdminNotification>? incomingSubscription;
  StreamSubscription<NotificationRealtimeStatus>? statusSubscription;
  Timer? pollTimer;

  Future<void> stopRealtime(Store<AppState> store) async {
    pollTimer?.cancel();
    pollTimer = null;
    await incomingSubscription?.cancel();
    incomingSubscription = null;
    await statusSubscription?.cancel();
    statusSubscription = null;
    await deps.notificationService.stopRealtime();
    store.dispatch(const NotificationsSessionClearedAction());
  }

  Future<void> refreshNotifications(
    Store<AppState> store, {
    required bool silent,
  }) async {
    final previousIds = store.state.notificationsState.items
        .map((item) => item.id)
        .toSet();
    final hadItems = previousIds.isNotEmpty;

    try {
      final items = await deps.notificationsRepository.fetchNotifications();
      store.dispatch(NotificationsLoadedAction(items, silent: silent));

      if (!hadItems) return;

      for (final item in items) {
        if (!previousIds.contains(item.id) && !item.isRead) {
          final preferences = store.state.settingsState.bundle.notifications;
          store.dispatch(
            IncomingNotificationAction(
              item,
              showToast: preferences.toastEnabled &&
                  preferences.isEnabledFor(item.category),
              showLocalAlert: false,
            ),
          );
        }
      }
    } catch (error) {
      store.dispatch(NotificationsFailedAction(_messageOf(error)));
    }
  }

  Future<void> startRealtime(Store<AppState> store) async {
    pollTimer?.cancel();
    await incomingSubscription?.cancel();
    await statusSubscription?.cancel();

    store.dispatch(
      const NotificationsConnectionChangedAction(
        NotificationRealtimeStatus.connecting,
      ),
    );

    final accessToken = await deps.secureStorage.readAccessToken();
    final userId = store.state.authState.currentUser?.id;

    await deps.notificationService.startRealtime(
      accessToken: accessToken,
      userId: userId,
    );

    incomingSubscription = deps.notificationService.incomingNotifications
        .listen((notification) {
          final preferences = store.state.settingsState.bundle.notifications;
          deps.notificationsRepository.cacheIncoming(notification);
          store.dispatch(
            const NotificationsConnectionChangedAction(
              NotificationRealtimeStatus.live,
            ),
          );
          store.dispatch(
            IncomingNotificationAction(
              notification,
              showToast: preferences.toastEnabled &&
                  preferences.isEnabledFor(notification.category),
              showLocalAlert:
                  preferences.localAlertsEnabled &&
                  preferences.isEnabledFor(notification.category),
            ),
          );
        });

    statusSubscription = deps.notificationService.statusChanges.listen((
      status,
    ) {
      store.dispatch(NotificationsConnectionChangedAction(status));
    });

    pollTimer = Timer.periodic(AppConfig.notificationPollInterval, (_) {
      if (!store.state.authState.isAuthenticated) return;
      store.dispatch(const LoadNotificationsAction(silent: true));
    });

    await refreshNotifications(store, silent: true);
  }

  return [
    TypedMiddleware<AppState, LoadNotificationsAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      await refreshNotifications(store, silent: action.silent);
    }).call,
    TypedMiddleware<AppState, StartNotificationsRealtimeAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      await startRealtime(store);
    }).call,
    TypedMiddleware<AppState, StopNotificationsRealtimeAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      await stopRealtime(store);
    }).call,
    TypedMiddleware<AppState, LoginSucceededAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const StartNotificationsRealtimeAction());
    }).call,
    TypedMiddleware<AppState, HydrateUserAction>((store, action, next) async {
      next(action);
      store.dispatch(const StartNotificationsRealtimeAction());
    }).call,
    TypedMiddleware<AppState, LogoutCompletedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      await stopRealtime(store);
    }).call,
    TypedMiddleware<AppState, IncomingNotificationAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      final settings = store.state.settingsState.bundle;
      final preferences = settings.notifications;
      if (!action.showLocalAlert) return;
      if (!preferences.isEnabledFor(action.notification.category)) return;
      if (!preferences.localAlertsEnabled &&
          !preferences.pushEnabled &&
          !preferences.desktopAlertsEnabled) {
        return;
      }

      try {
        await deps.notificationService.showLocalNotification(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          title: action.notification.title,
          body: action.notification.body,
        );
      } catch (_) {}
    }).call,
    TypedMiddleware<AppState, MarkNotificationReadRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(NotificationMarkedReadAction(action.notificationId));
      await deps.notificationsRepository.markRead(action.notificationId);
    }).call,
    TypedMiddleware<AppState, MarkAllNotificationsReadRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      final unreadIds = store.state.notificationsState.items
          .where((item) => !item.isRead)
          .map((item) => item.id)
          .toList(growable: false);
      for (final id in unreadIds) {
        store.dispatch(NotificationMarkedReadAction(id));
      }
      await deps.notificationsRepository.markAllRead(unreadIds);
    }).call,
    TypedMiddleware<AppState, NotificationBroadcastRequestedAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        await deps.notificationsRepository.broadcast(
          title: action.title,
          body: action.body,
          category: action.category,
          refType: action.refType,
          refId: action.refId,
        );

        final syntheticNotification = AdminNotification(
          id: 'LOCAL-${DateTime.now().microsecondsSinceEpoch}',
          title: action.title,
          body: action.body,
          category: action.category,
          createdAt: DateTime.now(),
          isRead: false,
          rawType: action.category.backendType,
          refType: action.refType,
          refId: action.refId,
          source: 'broadcast',
          audienceLabel: 'Queued broadcast',
        );
        deps.notificationsRepository.cacheIncoming(syntheticNotification);
        store.dispatch(
          IncomingNotificationAction(
            syntheticNotification,
            showToast: false,
            showLocalAlert: false,
          ),
        );
        store.dispatch(const NotificationBroadcastFinishedAction());
        action.onSuccess?.call();
      } catch (error) {
        final message = _messageOf(error);
        store.dispatch(NotificationsFailedAction(message));
        store.dispatch(const NotificationBroadcastFinishedAction());
        action.onError?.call(message);
      }
    }).call,
  ];
}

List<AdminNotification> _upsertNotification(
  List<AdminNotification> items,
  AdminNotification notification,
) {
  final map = <String, AdminNotification>{
    for (final item in items) item.id: item,
    notification.id: notification,
  };
  return _sortNotifications(map.values.toList(growable: false));
}

List<AdminNotification> _sortNotifications(List<AdminNotification> items) {
  final next = [...items]
    ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
  return List<AdminNotification>.unmodifiable(next);
}

String _messageOf(Object error) {
  if (error is AppException) return error.message;
  return error.toString();
}
