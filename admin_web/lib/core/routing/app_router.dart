import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_web/features/auth/presentation/auth_provider.dart';
import 'package:admin_web/features/auth/presentation/screens/login_screen.dart';
import 'package:admin_web/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:admin_web/features/students/presentation/screens/students_list_screen.dart';
import 'package:admin_web/features/students/presentation/screens/student_detail_screen.dart';
import 'package:admin_web/features/academic/presentation/screens/academic_structure_screen.dart';
import 'package:admin_web/features/staff/presentation/screens/staff_assignment_screen.dart';
import 'package:admin_web/features/schedule/presentation/screens/schedule_management_screen.dart';
import 'package:admin_web/features/settings/presentation/screens/system_settings_screen.dart';
import 'package:admin_web/core/ui/layout.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (!authState.isAuthenticated && state.uri.path != '/login') {
        return '/login';
      }
      if (authState.isAuthenticated && state.uri.path == '/login') {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/students',
            builder: (context, state) => const StudentsListScreen(),
          ),
          GoRoute(
            path: '/students/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'];
              return StudentDetailScreen(studentId: id == 'new' ? null : int.parse(id!));
            },
          ),
          GoRoute(
            path: '/academic',
            builder: (context, state) => const AcademicStructureScreen(),
          ),
          GoRoute(
            path: '/staff',
            builder: (context, state) => const StaffAssignmentScreen(),
          ),
          GoRoute(
            path: '/schedule',
            builder: (context, state) => const ScheduleManagementScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SystemSettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
