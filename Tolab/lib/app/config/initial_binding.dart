import 'package:get/get.dart';

import '../modules/auth/bindings/auth_binding.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    AuthBinding().dependencies();
  }
}
