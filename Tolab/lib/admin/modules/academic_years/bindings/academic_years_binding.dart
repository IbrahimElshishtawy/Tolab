import 'package:get/get.dart';

import '../../../data/repositories/admin/admin_entity_repositories.dart';
import '../controllers/academic_years_controller.dart';

class AcademicYearsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AcademicYearsController>(
      () => AcademicYearsController(Get.find<AcademicYearsRepository>()),
    );
  }
}
