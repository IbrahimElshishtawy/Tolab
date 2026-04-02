import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_admin/core/routing/route_paths.dart';
import '../../app_admin/modules/content_management/presentation/content_screen.dart';
import '../../app_admin/modules/course_offerings/presentation/course_offerings_screen.dart';
import '../../app_admin/modules/course_offerings/presentation/pages/course_offering_details_page.dart';
import '../../app_admin/modules/dashboard/presentation/dashboard_screen.dart'
    as admin_dashboard;
import '../../app_admin/modules/departments/presentation/department_details_screen.dart';
import '../../app_admin/modules/departments/presentation/departments_screen.dart';
import '../../app_admin/modules/enrollments/presentation/enrollments_screen.dart';
import '../../app_admin/modules/moderation/presentation/moderation_screen.dart';
import '../../app_admin/modules/notifications/presentation/notifications_screen.dart'
    as admin_notifications;
import '../../app_admin/modules/roles_permissions/presentation/roles_screen.dart';
import '../../app_admin/modules/schedule/presentation/schedule_screen.dart'
    as admin_schedule;
import '../../app_admin/modules/sections/presentation/sections_screen.dart';
import '../../app_admin/modules/settings/presentation/settings_screen.dart'
    as admin_settings;
import '../../app_admin/modules/staff/presentation/staff_screen.dart'
    as admin_staff;
import '../../app_admin/modules/students/presentation/students_screen.dart';
import '../../app_admin/modules/subjects/presentation/subjects_screen.dart'
    as admin_subjects;
import '../../app_admin/modules/uploads/presentation/uploads_screen.dart'
    as admin_uploads;
import '../../app_doctor_assistant/core/navigation/app_routes.dart'
    as staff_routes;
import '../../app_doctor_assistant/modules/admin/presentation/admin_screen.dart';
import '../../app_doctor_assistant/modules/dashboard/presentation/dashboard_screen.dart';
import '../../app_doctor_assistant/modules/lectures/presentation/lectures_screen.dart';
import '../../app_doctor_assistant/modules/notifications/presentation/notifications_screen.dart';
import '../../app_doctor_assistant/modules/quizzes/presentation/quizzes_screen.dart';
import '../../app_doctor_assistant/modules/schedule/presentation/schedule_screen.dart';
import '../../app_doctor_assistant/modules/section_content/presentation/section_content_screen.dart';
import '../../app_doctor_assistant/modules/settings/presentation/settings_screen.dart';
import '../../app_doctor_assistant/modules/staff/presentation/staff_screen.dart';
import '../../app_doctor_assistant/modules/subjects/presentation/subject_details_screen.dart';
import '../../app_doctor_assistant/modules/subjects/presentation/subjects_screen.dart';
import '../../app_doctor_assistant/modules/tasks/presentation/tasks_screen.dart';
import '../../app_doctor_assistant/modules/uploads/presentation/uploads_screen.dart';
import '../../features/admin/presentation/admin_shell.dart';
import '../../features/doctor_assistant/presentation/doctor_assistant_scope.dart';
import '../auth/presentation/forgot_password_screen.dart';
import '../auth/presentation/inactive_account_screen.dart';
import '../auth/presentation/launch_screen.dart';
import '../auth/presentation/login_screen.dart';
import '../auth/presentation/unauthorized_screen.dart';
import '../auth/state/auth_controller.dart';
import '../guards/auth_guard.dart';
import 'app_routes.dart';

class UnifiedAppRouter {
  UnifiedAppRouter(this._authController);

  final AuthController _authController;

  late final GoRouter router = GoRouter(
    initialLocation: UnifiedAppRoutes.launch,
    refreshListenable: _authController,
    redirect: (context, state) {
      return AuthGuard.redirect(_authController.state, state.uri.path);
    },
    routes: [
      GoRoute(
        path: UnifiedAppRoutes.root,
        redirect: (_, __) => UnifiedAppRoutes.launch,
      ),
      GoRoute(
        path: UnifiedAppRoutes.launch,
        builder: (context, state) => const LaunchScreen(),
      ),
      GoRoute(
        path: UnifiedAppRoutes.login,
        builder: (context, state) => const UnifiedLoginScreen(),
      ),
      GoRoute(
        path: UnifiedAppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: UnifiedAppRoutes.inactive,
        builder: (context, state) => const InactiveAccountScreen(),
      ),
      GoRoute(
        path: UnifiedAppRoutes.unauthorized,
        builder: (context, state) => const UnauthorizedScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(
          location: state.uri.path,
          child: child,
        ),
        routes: _adminRoutes,
      ),
      ..._doctorRoutes,
    ],
  );

  static Page<void> _noTransition(GoRouterState state, Widget child) {
    return NoTransitionPage<void>(key: state.pageKey, child: child);
  }

  List<RouteBase> get _adminRoutes => <RouteBase>[
    GoRoute(
      path: RoutePaths.dashboard,
      pageBuilder: (context, state) =>
          _noTransition(state, const admin_dashboard.DashboardScreen()),
    ),
    GoRoute(
      path: RoutePaths.students,
      pageBuilder: (context, state) =>
          _noTransition(state, const StudentsScreen()),
    ),
    GoRoute(
      path: RoutePaths.staff,
      pageBuilder: (context, state) =>
          _noTransition(state, const admin_staff.StaffScreen()),
    ),
    GoRoute(
      path: RoutePaths.departments,
      pageBuilder: (context, state) =>
          _noTransition(state, const DepartmentsScreen()),
    ),
    GoRoute(
      path: RoutePaths.departmentDetailsPattern,
      pageBuilder: (context, state) => _noTransition(
        state,
        DepartmentDetailsScreen(
          departmentId: state.pathParameters['departmentId'] ?? '',
        ),
      ),
    ),
    GoRoute(
      path: RoutePaths.sections,
      pageBuilder: (context, state) =>
          _noTransition(state, const SectionsScreen()),
    ),
    GoRoute(
      path: RoutePaths.subjects,
      pageBuilder: (context, state) =>
          _noTransition(state, const admin_subjects.SubjectsScreen()),
    ),
    GoRoute(
      path: RoutePaths.courseOfferings,
      pageBuilder: (context, state) =>
          _noTransition(state, const CourseOfferingsScreen()),
    ),
    GoRoute(
      path: RoutePaths.courseOfferingDetailsPattern,
      pageBuilder: (context, state) => _noTransition(
        state,
        CourseOfferingDetailsPage(
          offeringId: state.pathParameters['offeringId'] ?? '',
        ),
      ),
    ),
    GoRoute(
      path: RoutePaths.enrollments,
      pageBuilder: (context, state) =>
          _noTransition(state, const EnrollmentsScreen()),
    ),
    GoRoute(
      path: RoutePaths.content,
      pageBuilder: (context, state) =>
          _noTransition(state, const ContentScreen()),
    ),
    GoRoute(
      path: RoutePaths.schedule,
      pageBuilder: (context, state) =>
          _noTransition(state, const admin_schedule.ScheduleScreen()),
    ),
    GoRoute(
      path: RoutePaths.uploads,
      pageBuilder: (context, state) =>
          _noTransition(state, const admin_uploads.UploadsScreen()),
    ),
    GoRoute(
      path: RoutePaths.notifications,
      pageBuilder: (context, state) => _noTransition(
        state,
        const admin_notifications.NotificationsScreen(),
      ),
    ),
    GoRoute(
      path: RoutePaths.notificationsHistory,
      pageBuilder: (context, state) => _noTransition(
        state,
        const admin_notifications.NotificationsScreen(initialTabIndex: 1),
      ),
    ),
    GoRoute(
      path: RoutePaths.moderation,
      pageBuilder: (context, state) =>
          _noTransition(state, const ModerationScreen()),
    ),
    GoRoute(
      path: RoutePaths.roles,
      pageBuilder: (context, state) => _noTransition(state, const RolesScreen()),
    ),
    GoRoute(
      path: RoutePaths.settings,
      pageBuilder: (context, state) =>
          _noTransition(state, const admin_settings.SettingsScreen()),
    ),
  ];

  List<RouteBase> get _doctorRoutes => <RouteBase>[
    GoRoute(
      path: staff_routes.AppRoutes.dashboard,
      builder: (context, state) =>
          const DoctorAssistantScope(child: DashboardScreen()),
    ),
    GoRoute(
      path: staff_routes.AppRoutes.subjects,
      builder: (context, state) =>
          const DoctorAssistantScope(child: SubjectsScreen()),
    ),
    GoRoute(
      path: '${staff_routes.AppRoutes.subjects}/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return DoctorAssistantScope(child: SubjectDetailsScreen(subjectId: id));
      },
    ),
    GoRoute(
      path: staff_routes.AppRoutes.lectures,
      builder: (context, state) =>
          const DoctorAssistantScope(child: LecturesScreen()),
    ),
    GoRoute(
      path: staff_routes.AppRoutes.sectionContent,
      builder: (context, state) =>
          const DoctorAssistantScope(child: SectionContentScreen()),
    ),
    GoRoute(
      path: staff_routes.AppRoutes.quizzes,
      builder: (context, state) =>
          const DoctorAssistantScope(child: QuizzesScreen()),
    ),
    GoRoute(
      path: staff_routes.AppRoutes.tasks,
      builder: (context, state) =>
          const DoctorAssistantScope(child: TasksScreen()),
    ),
    GoRoute(
      path: staff_routes.AppRoutes.schedule,
      builder: (context, state) =>
          const DoctorAssistantScope(child: ScheduleScreen()),
    ),
    GoRoute(
      path: staff_routes.AppRoutes.notifications,
      builder: (context, state) =>
          const DoctorAssistantScope(child: NotificationsScreen()),
    ),
    GoRoute(
      path: staff_routes.AppRoutes.uploads,
      builder: (context, state) =>
          const DoctorAssistantScope(child: UploadsScreen()),
    ),
    GoRoute(
      path: staff_routes.AppRoutes.staff,
      builder: (context, state) => const DoctorAssistantScope(child: StaffScreen()),
    ),
    GoRoute(
      path: staff_routes.AppRoutes.admin,
      builder: (context, state) => const DoctorAssistantScope(child: AdminScreen()),
    ),
    GoRoute(
      path: staff_routes.AppRoutes.settings,
      builder: (context, state) =>
          const DoctorAssistantScope(child: SettingsScreen()),
    ),
  ];
}
