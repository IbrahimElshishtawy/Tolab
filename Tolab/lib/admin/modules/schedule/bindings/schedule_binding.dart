import 'package:get/get.dart';

import '../../../data/repositories/admin/admin_entity_repositories.dart';
import '../controllers/schedule_controller.dart';

class ScheduleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScheduleController>(
      () => ScheduleController(Get.find<ScheduleRepository>()),
    );
  }
}
