import 'package:flutter/foundation.dart';

class AppLogger {
  const AppLogger._();

  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('[Tolab] $message');
    }
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    debugPrint('[Tolab][Error] $message');
    if (error != null) {
      debugPrint('$error');
    }
    if (stackTrace != null) {
      debugPrint('$stackTrace');
    }
  }
}
