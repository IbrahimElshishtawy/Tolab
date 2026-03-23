import 'package:get/get.dart';

import '../../../core/services/app_service.dart';
import '../../../core/services/session_service.dart';
import '../../../routes/app_routes.dart';
import '../../auth/repositories/auth_repository.dart';

class SplashController extends GetxController {
  SplashController(
    this._sessionService,
    this._authRepository,
    this._appService,
  );

  final SessionService _sessionService;
  final AuthRepository _authRepository;
  final AppService _appService;

  @override
  void onReady() {
    super.onReady();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(milliseconds: 1100));

    if (_sessionService.isAuthenticated.value) {
      final result = await _authRepository.restoreUser();
      return result.when(
        success: (_) => Get.offAllNamed(AppRoutes.shell),
        failure: (_) => Get.offAllNamed(AppRoutes.login),
      );
    }

    final nextRoute = _appService.isOnboardingSeen.value
        ? AppRoutes.login
        : AppRoutes.onboarding;
    Get.offAllNamed(nextRoute);
  }
}
