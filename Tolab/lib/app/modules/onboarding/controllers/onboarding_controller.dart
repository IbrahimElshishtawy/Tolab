import 'package:get/get.dart';

import '../../../core/services/app_service.dart';
import '../../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  OnboardingController(this._appService);

  final AppService _appService;
  final RxInt pageIndex = 0.obs;

  Future<void> complete() async {
    await _appService.markOnboardingSeen();
    Get.offAllNamed(AppRoutes.login);
  }
}
