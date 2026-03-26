import 'package:get/get.dart';

import '../modules/shell/controllers/shell_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShellController>(ShellController.new, fenix: true);
  }
}
