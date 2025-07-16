// lib/core/services/app_links_handler.dart

import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';

class AppLinksHandler {
  final AppLinks _appLinks = AppLinks();

  Future<void> handleInitialUri() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        if (kDebugMode) {
          print("🚀 Initial URI: $uri");
        }
        // 👇 يمكنك التوجيه إلى صفحة هنا بناءً على الرابط
        // Example: navigatorKey.currentState?.pushNamed('/page', arguments: uri);
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error in initial URI: $e");
      }
    }
  }

  void listenToUriChanges() {
    _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          if (kDebugMode) {
            print("🔄 URI Changed: $uri");
          }
          // 👇 يمكنك التوجيه إلى صفحة هنا بناءً على الرابط
          // Example: navigatorKey.currentState?.pushNamed('/page', arguments: uri);
        }
      },
      onError: (err) {
        if (kDebugMode) {
          print("❌ URI Stream Error: $err");
        }
      },
    );
  }
}
