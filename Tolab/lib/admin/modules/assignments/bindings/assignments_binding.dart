import 'package:get/get.dart';

import '../../../data/repositories/admin/admin_entity_repositories.dart';
import '../controllers/assignments_controller.dart';

class AssignmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AssignmentsController>(
      () => AssignmentsController(Get.find<AssignmentsRepository>()),
    );
  }
}
