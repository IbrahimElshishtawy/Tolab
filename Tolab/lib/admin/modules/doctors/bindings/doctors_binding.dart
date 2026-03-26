import 'package:get/get.dart';

import '../../../data/repositories/admin/admin_entity_repositories.dart';
import '../controllers/doctors_controller.dart';

class DoctorsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorsController>(
      () => DoctorsController(Get.find<DoctorsRepository>()),
    );
  }
}
