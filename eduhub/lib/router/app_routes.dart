// lib/router/app_routes.dart
// ignore_for_file: file_names

import 'package:eduhub/apps/tolab_admin_panel/lib/src/presentation/features/dashboard/pages/Dashboard_Page.dart';
//import 'package:eduhub/apps/tolab_student_desktop/lib/src/presentation/desktop/dashboard/layouts/student_desktop_home_page.dart';
import 'package:flutter/material.dart';
import '../spa/Splach_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String studentDesktopHome = '/student/desktop/home';
  static const String dashboard = '/dashboard';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const Splashscreen());
      // case AppRoutes.studentDesktopHome:
      //   return MaterialPageRoute(
      //     builder: (_) => const StudentDesktopHomePage(),
      //   );
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      default:
        return MaterialPageRoute(builder: (_) => const Splashscreen());
    }
  }
}
