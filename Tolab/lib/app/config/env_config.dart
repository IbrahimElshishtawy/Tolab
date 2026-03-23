enum AppFlavor { dev, staging, production }

class EnvConfig {
  const EnvConfig._();

  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Tolab',
  );

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  static const String connectTimeoutSeconds = String.fromEnvironment(
    'CONNECT_TIMEOUT_SECONDS',
    defaultValue: '20',
  );

  static const String receiveTimeoutSeconds = String.fromEnvironment(
    'RECEIVE_TIMEOUT_SECONDS',
    defaultValue: '20',
  );

  static const String refreshPath = String.fromEnvironment(
    'REFRESH_PATH',
    defaultValue: '/auth/refresh',
  );

  static const String loginPath = String.fromEnvironment(
    'LOGIN_PATH',
    defaultValue: '/auth/login',
  );

  static AppFlavor get flavor {
    const raw = String.fromEnvironment('APP_FLAVOR', defaultValue: 'dev');
    return AppFlavor.values.firstWhere(
      (item) => item.name == raw,
      orElse: () => AppFlavor.dev,
    );
  }

  static bool get isProduction => flavor == AppFlavor.production;
}
