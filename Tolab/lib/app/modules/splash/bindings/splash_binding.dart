import 'package:get/get.dart';

import '../../../core/services/app_service.dart';
import '../../../core/services/session_service.dart';
import '../../auth/repositories/auth_repository.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(
      SplashController(
        Get.find<SessionService>(),
        Get.find<AuthRepository>(),
        Get.find<AppService>(),
      ),
    );
  }
}
