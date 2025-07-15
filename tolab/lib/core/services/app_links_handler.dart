import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class AppLinksHandler {
  final AppLinks _appLinks = AppLinks();

  Future<void> handleInitialUri() async {
    try {
      final uri = await _appLinks.getInitialLink();

      if (uri != null) {
        if (kDebugMode) print("🔗 Received URI: $uri");
        await Supabase.instance.client.auth.exchangeCodeForSession(
          uri as String,
        );
      }
    } catch (e) {
      if (kDebugMode) print("❌ URI Error: $e");
    }
  }

  void listenToUriChanges() {
    _appLinks.uriLinkStream.listen(
      (uri) async {
        if (kDebugMode) print("📲 URI Updated: $uri");
        await Supabase.instance.client.auth.exchangeCodeForSession(
          uri as String,
        );
      },
      onError: (err) {
        if (kDebugMode) print("❌ URI stream error: $err");
      },
    );
  }
}
