import 'package:get/get.dart';

import '../../../data/repositories/admin/notifications_repository.dart';
import '../controllers/notifications_controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationsController>(
      () => NotificationsController(Get.find<NotificationsRepository>()),
    );
  }
}
