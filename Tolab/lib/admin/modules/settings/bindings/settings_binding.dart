import 'package:get/get.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/services/theme_service.dart';
import '../../../data/repositories/admin/settings_repository.dart';
import '../controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(
      () => SettingsController(
        Get.find<SettingsRepository>(),
        Get.find<ThemeService>(),
        Get.find<NotificationService>(),
      ),
    );
  }
}
