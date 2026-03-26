class AdminConfig {
  const AdminConfig._();

  static const String appName = 'Tolab Admin';
  static const bool useMockData = true;
  static const String baseUrl = 'https://api.tolab.local/api';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
