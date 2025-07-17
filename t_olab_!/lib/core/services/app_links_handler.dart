// lib/core/services/app_links_handler.dart

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

class AppLinksHandler {
  final AppLinks _appLinks = AppLinks();

  /// تشغيل الاستماع على الروابط
  void initialize() {
    _appLinks.uriLinkStream.listen(
      (Uri uri) {
        if (kDebugMode) {
          print("🔗 Received App Link: $uri");
        }
        // هنا يمكنك التوجيه إلى صفحة معينة حسب uri.path أو uri.queryParameters
      },
      onError: (err) {
        if (kDebugMode) {
          print("❌ App Link Error: $err");
        }
      },
    );
  }
}
