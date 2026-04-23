enum BackendMode { mock, api }

class BackendModeConfig {
  const BackendModeConfig._();

  static const String _rawMode = String.fromEnvironment(
    'TOLAB_BACKEND_MODE',
    defaultValue: 'mock',
  );

  static BackendMode get mode {
    switch (_rawMode.trim().toLowerCase()) {
      case 'api':
      case 'remote':
      case 'backend':
        return BackendMode.api;
      case 'mock':
      default:
        return BackendMode.mock;
    }
  }

  static bool get isMockMode => mode == BackendMode.mock;

  static bool get isApiMode => mode == BackendMode.api;
}
