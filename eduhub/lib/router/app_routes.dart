// lib/router/app_routes.dart
// ignore_for_file: constant_identifier_names, file_names

import 'package:eduhub/apps/tolab_admin_panel/lib/src/presentation/features/auth/pages/login_page.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/presentation/features/dashboard/pages/Dashboard_Page.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/presentation/features/students_management/pages/students_page.dart';
import 'package:flutter/material.dart';

import '../spa/Splach_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String dashboard = '/dashboard';
  static const String login_dashboard = '/login_Dashboard';
  static const String students = '/students';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const Splashscreen());

      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());

      case AppRoutes.login_dashboard:
        return MaterialPageRoute(builder: (_) => const LoginPage_Dashboard());

      case AppRoutes.students:
        return MaterialPageRoute(builder: (_) => const StudentsPage());
      default:
        return MaterialPageRoute(builder: (_) => const Splashscreen());
    }
  }
}
