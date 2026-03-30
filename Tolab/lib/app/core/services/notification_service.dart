import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../shared/models/notification_models.dart';
import '../../../firebase_options.dart';
import '../config/app_config.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}

  final plugin = FlutterLocalNotificationsPlugin();
  const initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
    macOS: DarwinInitializationSettings(),
    windows: WindowsInitializationSettings(
      appName: 'Tolab Admin',
      appUserModelId: 'com.tolab.admin.desktop',
      guid: '7f3880aa-d713-4d31-bc7d-d48eb0ed7d57',
    ),
  );
  await plugin.initialize(initializationSettings);

  final notification = message.notification;
  if (notification == null) return;

  await plugin.show(
    DateTime.now().millisecondsSinceEpoch.remainder(100000),
    notification.title,
    notification.body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'tolab_admin_channel',
        'Tolab Admin',
        channelDescription: 'Operational updates and admin broadcasts',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
      windows: WindowsNotificationDetails(),
    ),
  );
}

class NotificationService {
  NotificationService._(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  final StreamController<AdminNotification> _incomingController =
      StreamController<AdminNotification>.broadcast();
  final StreamController<NotificationRealtimeStatus> _statusController =
      StreamController<NotificationRealtimeStatus>.broadcast();

  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<dynamic>? _socketSubscription;
  WebSocketChannel? _socketChannel;
  bool _firebaseInitialized = false;
  bool _started = false;

  Stream<AdminNotification> get incomingNotifications =>
      _incomingController.stream;
  Stream<NotificationRealtimeStatus> get statusChanges =>
      _statusController.stream;

  static Future<NotificationService> initialize() async {
    final plugin = FlutterLocalNotificationsPlugin();
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
      windows: WindowsInitializationSettings(
        appName: 'Tolab Admin',
        appUserModelId: 'com.tolab.admin.desktop',
        guid: '7f3880aa-d713-4d31-bc7d-d48eb0ed7d57',
      ),
    );
    await plugin.initialize(settings);
    await _requestLocalNotificationPermissions(plugin);

    final service = NotificationService._(plugin);
    await service._initializeFirebaseMessagingIfSupported();
    return service;
  }

  Future<void> startRealtime({String? accessToken, String? userId}) async {
    if (_started) {
      await stopRealtime();
    }
    _started = true;
    _statusController.add(NotificationRealtimeStatus.connecting);

    await _initializeFirebaseMessagingIfSupported();
    _listenToForegroundMessages();
    _connectWebSocket(accessToken: accessToken, userId: userId);
  }

  Future<void> stopRealtime() async {
    _started = false;
    await _foregroundMessageSubscription?.cancel();
    _foregroundMessageSubscription = null;
    await _socketSubscription?.cancel();
    await _socketChannel?.sink.close();
    _socketSubscription = null;
    _socketChannel = null;
    _statusController.add(NotificationRealtimeStatus.idle);
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
  }) {
    return _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tolab_admin_channel',
          'Tolab Admin',
          channelDescription: 'Operational updates and admin broadcasts',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
        windows: WindowsNotificationDetails(),
      ),
    );
  }

  Future<String?> getPushToken() async {
    if (!_supportsFirebaseMessaging) return null;
    try {
      await _initializeFirebaseMessagingIfSupported();
      return FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }

  Future<void> _initializeFirebaseMessagingIfSupported() async {
    if (_firebaseInitialized || !_supportsFirebaseMessaging) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (_) {}

    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      _firebaseInitialized = true;
    } catch (_) {
      _firebaseInitialized = false;
    }
  }

  void _listenToForegroundMessages() {
    if (!_firebaseInitialized || _foregroundMessageSubscription != null) return;

    _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen((
      message,
    ) {
      final notification = _notificationFromRemoteMessage(message);
      if (notification == null) return;
      _incomingController.add(notification);
      _statusController.add(NotificationRealtimeStatus.live);
    });
  }

  void _connectWebSocket({String? accessToken, String? userId}) {
    final url = AppConfig.notificationSocketUrl.trim();
    if (url.isEmpty) {
      _statusController.add(NotificationRealtimeStatus.polling);
      return;
    }

    try {
      final baseUri = Uri.parse(url);
      final queryParameters = <String, String>{
        ...baseUri.queryParameters,
        if (accessToken != null && accessToken.isNotEmpty) 'token': accessToken,
        if (userId != null && userId.isNotEmpty) 'user_id': userId,
      };
      final uri = baseUri.replace(queryParameters: queryParameters);

      _socketChannel = WebSocketChannel.connect(uri);
      _socketSubscription = _socketChannel!.stream.listen(
        (event) {
          final payload = _decodeSocketPayload(event);
          if (payload == null) return;
          final notification = AdminNotification.fromMessagePayload(
            payload,
            source: 'socket',
          );
          _incomingController.add(notification);
          _statusController.add(NotificationRealtimeStatus.live);
        },
        onError: (_) {
          _statusController.add(NotificationRealtimeStatus.polling);
        },
        onDone: () {
          if (_started) {
            _statusController.add(NotificationRealtimeStatus.disconnected);
          }
        },
        cancelOnError: true,
      );
    } catch (_) {
      _statusController.add(NotificationRealtimeStatus.polling);
    }
  }

  AdminNotification? _notificationFromRemoteMessage(RemoteMessage message) {
    final data = <String, dynamic>{...message.data};
    final remoteNotification = message.notification;
    if (remoteNotification != null) {
      data.putIfAbsent(
        'title',
        () => remoteNotification.title ?? 'Notification',
      );
      data.putIfAbsent('body', () => remoteNotification.body ?? '');
    }
    if (data.isEmpty) return null;
    return AdminNotification.fromMessagePayload(data, source: 'push');
  }

  Map<String, dynamic>? _decodeSocketPayload(dynamic event) {
    if (event is Map<String, dynamic>) return event;
    if (event is String && event.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(event);
        if (decoded is Map<String, dynamic>) {
          if (decoded['notification'] is Map<String, dynamic>) {
            return Map<String, dynamic>.from(
              decoded['notification'] as Map<String, dynamic>,
            );
          }
          if (decoded['data'] is Map<String, dynamic>) {
            return Map<String, dynamic>.from(
              decoded['data'] as Map<String, dynamic>,
            );
          }
          return decoded;
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static Future<void> _requestLocalNotificationPermissions(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    try {
      await plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (_) {}

    try {
      await plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (_) {}

    try {
      await plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (_) {}
  }

  bool get _supportsFirebaseMessaging {
    if (!AppConfig.enableFirebaseMessaging) return false;
    if (kIsWeb) return true;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS => true,
      _ => false,
    };
  }
}
