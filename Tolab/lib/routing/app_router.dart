import 'package:flutter/material.dart';
import 'package:tolab_fci/presentation/pages/dashboard_screen.dart';
import 'package:tolab_fci/presentation/pages/users_list_screen.dart';
import 'package:tolab_fci/presentation/pages/courses_list_screen.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String users = '/users';
  static const String courses = '/courses';
  static const String students = '/students';
  static const String settings = '/settings';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case AppRoutes.users:
        return MaterialPageRoute(builder: (_) => const UsersListScreen());
      case AppRoutes.courses:
        return MaterialPageRoute(builder: (_) => const CoursesListScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
