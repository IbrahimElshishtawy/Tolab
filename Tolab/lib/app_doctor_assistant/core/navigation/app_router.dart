import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';

import '../../modules/admin/presentation/admin_screen.dart';
import '../../modules/auth/presentation/forgot_password_screen.dart';
import '../../modules/auth/presentation/login_screen.dart';
import '../../modules/dashboard/presentation/dashboard_screen.dart';
import '../../modules/groups/presentation/add_post_page.dart';
import '../../modules/groups/presentation/subject_group_page.dart';
import '../../modules/lectures/presentation/add_lecture_page.dart';
import '../../modules/lectures/presentation/lectures_screen.dart';
import '../../modules/notifications/presentation/notifications_screen.dart';
import '../../modules/quizzes/presentation/quizzes_screen.dart';
import '../../modules/results/presentation/grade_entry_page.dart';
import '../../modules/results/presentation/results_screen.dart';
import '../../modules/results/presentation/subject_results_page.dart';
import '../../modules/schedule/presentation/schedule_screen.dart';
import '../../modules/section_content/presentation/section_content_screen.dart';
import '../../modules/settings/presentation/settings_screen.dart';
import '../../modules/staff/presentation/staff_screen.dart';
import '../../modules/students/presentation/students_screen.dart';
import '../../modules/subjects/presentation/subject_details_screen.dart';
import '../../modules/subjects/presentation/subjects_screen.dart';
import '../../modules/tasks/presentation/tasks_screen.dart';

import '../../modules/announcements/presentation/announcements_screen.dart';
import '../../modules/analytics/presentation/analytics_screen.dart';
import '../../state/app_state.dart';
import 'app_routes.dart';

GoRouter createAppRouter(Store<DoctorAssistantAppState> store) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: _StoreRefreshListenable(store.onChange),
    redirect: (context, state) {
      final session = store.state.sessionState;
      final isAuthenticated = session.isAuthenticated;
      final isAuthRoute =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.forgotPassword;

      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.login;
      }

      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.subjects,
        builder: (context, state) => const SubjectsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return SubjectDetailsScreen(subjectId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.lectures,
        builder: (context, state) => const LecturesScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) {
              final subjectId = int.tryParse(
                state.uri.queryParameters['subjectId'] ?? '',
              );
              return AddLecturePage(initialSubjectId: subjectId);
            },
          ),
          GoRoute(
            path: 'edit/:lectureId',
            builder: (context, state) {
              final id =
                  int.tryParse(state.pathParameters['lectureId'] ?? '') ?? 0;
              return AddLecturePage(lectureId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.sectionContent,
        builder: (context, state) => const SectionContentScreen(),
      ),
      GoRoute(
        path: AppRoutes.quizzes,
        builder: (context, state) => const QuizzesScreen(),
      ),
      GoRoute(
        path: AppRoutes.tasks,
        builder: (context, state) => const TasksScreen(),
      ),
      GoRoute(
        path: AppRoutes.results,
        builder: (context, state) => const ResultsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return SubjectResultsPage(subjectId: id);
            },
            routes: [
              GoRoute(
                path: 'grade-entry',
                builder: (context, state) {
                  final id =
                      int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                  return GradeEntryPage(subjectId: id);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.students,
        builder: (context, state) => const StudentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.schedule,
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.announcements,
        builder: (context, state) => const AnnouncementsScreen(),
      ),
      GoRoute(
        path: AppRoutes.analytics,
        builder: (context, state) => const AnalyticsScreen(),
      ),

      GoRoute(
        path: AppRoutes.staff,
        builder: (context, state) => const StaffScreen(),
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (context, state) => const AdminScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.subjects}/:id/group',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return SubjectGroupPage(subjectId: id);
        },
      ),
      GoRoute(
        path: '${AppRoutes.subjects}/:id/group/new',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return AddPostPage(subjectId: id);
        },
      ),
    ],
  );
}

class _StoreRefreshListenable extends ChangeNotifier {
  _StoreRefreshListenable(Stream<DoctorAssistantAppState> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<DoctorAssistantAppState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
