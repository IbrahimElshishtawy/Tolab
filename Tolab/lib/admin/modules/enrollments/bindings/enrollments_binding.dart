import 'package:get/get.dart';

import '../../../data/repositories/admin/admin_entity_repositories.dart';
import '../controllers/enrollments_controller.dart';

class EnrollmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EnrollmentsController>(
      () => EnrollmentsController(Get.find<EnrollmentsRepository>()),
    );
  }
}
