import 'package:get/get.dart';

import '../../../data/repositories/admin/dashboard_repository.dart';
import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(
      () => DashboardController(Get.find<DashboardRepository>()),
    );
  }
}
