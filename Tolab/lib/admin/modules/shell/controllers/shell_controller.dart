import 'package:get/get.dart';

import '../../shared/models/navigation_item.dart';

class ShellController extends GetxController {
  final isSidebarCollapsed = false.obs;

  NavigationItem get currentItem => NavigationItem.fromRoute(Get.currentRoute);

  void toggleSidebar() {
    isSidebarCollapsed.toggle();
  }

  void goTo(NavigationItem item) {
    Get.offAllNamed(item.route);
  }
}
