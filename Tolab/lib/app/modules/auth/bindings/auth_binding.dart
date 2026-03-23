import 'package:get/get.dart';

import '../../../core/services/session_service.dart';
import '../controllers/auth_controller.dart';
import '../repositories/auth_repository.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(
      () => AuthController(
        Get.find<AuthRepository>(),
        Get.find<SessionService>(),
      ),
      fenix: true,
    );
  }
}
