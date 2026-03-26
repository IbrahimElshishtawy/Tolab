import 'package:get/get.dart';

import '../../../data/repositories/admin/admin_entity_repositories.dart';
import '../controllers/departments_controller.dart';

class DepartmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DepartmentsController>(
      () => DepartmentsController(Get.find<DepartmentsRepository>()),
    );
  }
}
