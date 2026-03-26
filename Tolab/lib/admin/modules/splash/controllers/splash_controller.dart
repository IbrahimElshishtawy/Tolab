import 'package:get/get.dart';

import '../../../core/services/session_service.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  SplashController(this._sessionService);

  final SessionService _sessionService;

  @override
  void onReady() {
    super.onReady();
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      Get.offAllNamed(
        _sessionService.isAuthenticated ? AppRoutes.dashboard : AppRoutes.login,
      );
    });
  }
}
