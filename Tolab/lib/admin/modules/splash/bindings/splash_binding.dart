import 'package:get/get.dart';

import '../../../core/services/session_service.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
      () => SplashController(Get.find<SessionService>()),
    );
  }
}
