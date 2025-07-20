import 'package:app_links/app_links.dart';

class AppLinksHandler {
  static final AppLinks _appLinks = AppLinks();

  static Future<void> init() async {
    try {
      // الطريقة الجديدة للحصول على الرابط الأول عند تشغيل التطبيق
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        print('Initial URI: $initialUri');
        // تعامل مع الرابط هنا
      }
    } catch (e) {
      print('Error getting initial URI: $e');
    }

    // الاستماع لأي روابط أثناء تشغيل التطبيق
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        print('Received deep link: $uri');
        // تعامل مع الرابط هنا أيضاً
      }
    });
  }
}
