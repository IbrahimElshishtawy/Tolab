// ignore_for_file: avoid_print

import 'package:uni_links/uni_links.dart';
import 'dart:async';

class AppLinksHandler {
  Future<void> handleInitialUri() async {
    try {
      final uri = await getInitialUri();
      if (uri != null) {
        print("🚀 Initial URI: $uri");
        // التعامل مع الرابط
      }
    } catch (e) {
      print("❌ Error in initial URI: $e");
    }
  }

  void listenToUriChanges() {
    uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          print("🔄 URI Changed: $uri");
          // التعامل مع الرابط
        }
      },
      onError: (err) {
        print("❌ URI Stream Error: $err");
      },
    );
  }
}
