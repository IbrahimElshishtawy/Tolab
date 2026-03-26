import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../constants/storage_keys.dart';
import '../storage/local_storage_service.dart';

class NotificationService extends GetxService {
  NotificationService(this._storage);

  final LocalStorageService _storage;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final allowPush = true.obs;
  final allowLocal = true.obs;

  Future<NotificationService> init() async {
    final saved = _storage.read(StorageKeys.notificationSettings);
    if (saved != null) {
      final data = jsonDecode(saved) as Map<String, dynamic>;
      allowPush.value = data['allowPush'] as bool? ?? true;
      allowLocal.value = data['allowLocal'] as bool? ?? true;
    }

    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
        macOS: DarwinInitializationSettings(),
      ),
    );
    return this;
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
}
