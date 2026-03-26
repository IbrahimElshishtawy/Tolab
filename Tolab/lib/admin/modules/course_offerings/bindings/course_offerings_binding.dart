import 'package:get/get.dart';

import '../../../data/repositories/admin/admin_entity_repositories.dart';
import '../controllers/course_offerings_controller.dart';

class CourseOfferingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CourseOfferingsController>(
      () => CourseOfferingsController(Get.find<CourseOfferingsRepository>()),
    );
  }
}
