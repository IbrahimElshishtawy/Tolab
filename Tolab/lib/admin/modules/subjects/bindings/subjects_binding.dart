import 'package:get/get.dart';

import '../../../data/repositories/admin/admin_entity_repositories.dart';
import '../controllers/subjects_controller.dart';

class SubjectsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubjectsController>(
      () => SubjectsController(Get.find<SubjectsRepository>()),
    );
  }
}
