import 'package:get/get.dart';

import '../../../data/repositories/admin/admin_entity_repositories.dart';
import '../controllers/batches_controller.dart';

class BatchesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BatchesController>(
      () => BatchesController(Get.find<BatchesRepository>()),
    );
  }
}
