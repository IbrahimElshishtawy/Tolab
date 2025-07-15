import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppLinksHandler {
  final AppLinks _appLinks = AppLinks();

  Future<void> handleInitialUri() async {
    try {
      final Uri? url = await _appLinks.getInitialLink();
      if (url != null) {
        if (kDebugMode) print("🔗 Received URI: $url");
        await Supabase.instance.client.auth.exchangeCodeForSession(
          url.toString(),
        );
      }
    } catch (e) {
      if (kDebugMode) print("❌ URI Error: $e");
    }
  }

  void listenToUriChanges() {
    _appLinks.uriLinkStream.listen(
      (Uri? uri) async {
        if (uri != null) {
          if (kDebugMode) print("📲 URI Updated: $uri");
          await Supabase.instance.client.auth.exchangeCodeForSession(
            uri.toString(),
          ); // ✅ صح
        }
      },
      onError: (err) {
        if (kDebugMode) print("❌ URI stream error: $err");
      },
    );
  }
}
