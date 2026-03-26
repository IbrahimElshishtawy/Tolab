import 'package:get/get.dart';

import '../../../data/repositories/admin/admin_entity_repositories.dart';
import '../controllers/assistants_controller.dart';

class AssistantsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AssistantsController>(
      () => AssistantsController(Get.find<AssistantsRepository>()),
    );
  }
}
