class AppConfig {
  const AppConfig._();

  static const String appName = 'Tolab Admin';
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api',
  );
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration notificationPollInterval = Duration(seconds: 45);
  static const bool enableVerboseNetworkLogs = true;
  static const bool enableFirebaseMessaging = bool.fromEnvironment(
    'ENABLE_FIREBASE_MESSAGING',
    defaultValue: true,
  );
  static const String notificationSocketUrl = String.fromEnvironment(
    'NOTIFICATIONS_WS_URL',
    defaultValue: 'ws://127.0.0.1:8000/ws/admin/notifications',
  );
}
