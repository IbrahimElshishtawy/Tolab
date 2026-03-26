import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

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
    return NotificationService(plugin);
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
}
