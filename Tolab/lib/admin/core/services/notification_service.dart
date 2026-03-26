import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../constants/storage_keys.dart';
import '../storage/local_storage_service.dart';

class NotificationService extends GetxService {
  NotificationService(this._storage);

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'tolab_high_importance_channel',
    'Tolab Notifications',
    description: 'Important notifications for Tolab users.',
    importance: Importance.high,
  );

  final LocalStorageService _storage;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final allowPush = true.obs;
  final allowLocal = true.obs;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static bool _localNotificationsReady = false;

  Future<NotificationService> init() async {
    final saved = _storage.read(StorageKeys.notificationSettings);
    if (saved != null) {
      final data = jsonDecode(saved) as Map<String, dynamic>;
      allowPush.value = data['allowPush'] as bool? ?? true;
      allowLocal.value = data['allowLocal'] as bool? ?? true;
    }

    await ensureLocalNotificationsInitialized();
    await _requestNotificationPermissions();
    await _configureFirebaseMessaging();

    final token = await _messaging.getToken();
    if (token != null) {
      await _storage.write(StorageKeys.fcmToken, token);
      debugPrint('FCM token: $token');
    }

    _messaging.onTokenRefresh.listen((token) async {
      await _storage.write(StorageKeys.fcmToken, token);
      debugPrint('FCM token refreshed: $token');
    });

    return this;
  }

  static Future<void> ensureLocalNotificationsInitialized() async {
    if (_localNotificationsReady) {
      return;
    }

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
        macOS: DarwinInitializationSettings(),
      ),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    _localNotificationsReady = true;
  }

  Future<void> _requestNotificationPermissions() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _configureFirebaseMessaging() async {
    await _messaging.setAutoInitEnabled(true);
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((message) async {
      if (!allowPush.value || !allowLocal.value) {
        return;
      }

      await showRemoteMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint(
        'Notification opened app: ${message.messageId} ${message.data}',
      );
    });
  }

  Future<void> savePreferences({
    required bool push,
    required bool local,
  }) async {
    allowPush.value = push;
    allowLocal.value = local;
    await _storage.write(
      StorageKeys.notificationSettings,
      jsonEncode({'allowPush': push, 'allowLocal': local}),
    );
  }

  static Future<void> showRemoteMessage(RemoteMessage message) async {
    final remoteNotification = message.notification;
    final title =
        remoteNotification?.title ?? message.data['title']?.toString();
    final body = remoteNotification?.body ?? message.data['body']?.toString();

    if (title == null && body == null) {
      return;
    }

    await ensureLocalNotificationsInitialized();

    await _localNotifications.show(
      message.messageId?.hashCode ?? message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
        macOS: const DarwinNotificationDetails(),
      ),
    );
  }
}
