import 'package:get/get.dart';

import '../../../data/repositories/admin/admin_entity_repositories.dart';
import '../controllers/students_controller.dart';

class StudentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentsController>(
      () => StudentsController(Get.find<StudentsRepository>()),
    );
  }
}
