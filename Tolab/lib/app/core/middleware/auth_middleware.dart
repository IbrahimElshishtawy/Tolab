import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../services/session_service.dart';
import '../../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  AuthMiddleware({this.allowGuestsOnly = false});

  final bool allowGuestsOnly;

  @override
  RouteSettings? redirect(String? route) {
    final session = Get.find<SessionService>();
    final isAuthenticated = session.isAuthenticated.value;

    if (allowGuestsOnly && isAuthenticated) {
      return const RouteSettings(name: AppRoutes.shell);
    }

    if (!allowGuestsOnly && !isAuthenticated) {
      return const RouteSettings(name: AppRoutes.login);
    }

    return null;
  }
}
