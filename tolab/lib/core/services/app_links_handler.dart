import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

class AppLinksHandler {
  final AppLinks _appLinks = AppLinks();

  void initialize() {
    // استماع لأي رابط حتى أول رابط يدخل التطبيق
    _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null && kDebugMode) {
          if (kDebugMode) {
            print("🔗 Received App Link: $uri");
          }
        }
        // مكانك هنا عشان توجه للمحتوى المناسب بناء على الرابط
      },
      onError: (err) {
        if (kDebugMode) {
          print("❌ App Link Error: $err");
        }
      },
    );
  }
}
