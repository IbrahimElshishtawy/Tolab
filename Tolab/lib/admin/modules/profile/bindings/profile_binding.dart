import 'package:get/get.dart';

import '../../../data/repositories/admin/profile_repository.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
      () => ProfileController(Get.find<ProfileRepository>()),
    );
  }
}
