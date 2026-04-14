import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/assignments/presentation/pages/assignment_upload_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/verify_national_id_page.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/widgets/home_navigation_shell.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/quizzes/presentation/pages/quiz_entry_page.dart';
import '../../features/quizzes/presentation/pages/quizzes_page.dart';
import '../../features/results/presentation/pages/results_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/subject_details/presentation/pages/subject_details_page.dart';
import '../../features/subjects/presentation/pages/subjects_page.dart';
import '../../features/summaries/presentation/pages/add_summary_page.dart';
import '../../features/timetable/presentation/pages/timetable_page.dart';
import 'route_names.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final bootstrap = ref.watch(sessionBootstrapProvider);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/verify-national-id',
        name: RouteNames.verifyNationalId,
        builder: (context, state) => const VerifyNationalIdPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: RouteNames.home,
                builder: (context, state) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'quizzes',
                    name: RouteNames.quizzes,
                    builder: (context, state) => const QuizzesPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/subjects',
                name: RouteNames.subjects,
                builder: (context, state) => const SubjectsPage(),
                routes: [
                  GoRoute(
                    path: ':subjectId',
                    name: RouteNames.subjectDetails,
                    builder: (context, state) => SubjectDetailsPage(
                      subjectId: state.pathParameters['subjectId']!,
                      initialTab: state.uri.queryParameters['tab'],
                    ),
                    routes: [
                      GoRoute(
                        path: 'quizzes/:quizId',
                        name: RouteNames.quizEntry,
                        builder: (context, state) => QuizEntryPage(
                          subjectId: state.pathParameters['subjectId']!,
                          quizId: state.pathParameters['quizId']!,
                        ),
                      ),
                      GoRoute(
                        path: 'assignments/:taskId/upload',
                        name: RouteNames.assignmentUpload,
                        builder: (context, state) => AssignmentUploadPage(
                          subjectId: state.pathParameters['subjectId']!,
                          taskId: state.pathParameters['taskId']!,
                        ),
                      ),
                      GoRoute(
                        path: 'add-summary',
                        name: RouteNames.addSummary,
                        builder: (context, state) => AddSummaryPage(
                          subjectId: state.pathParameters['subjectId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/timetable',
                name: RouteNames.timetable,
                builder: (context, state) => const TimetablePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                name: RouteNames.notifications,
                builder: (context, state) => const NotificationsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: RouteNames.profile,
                builder: (context, state) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: 'results',
                    name: RouteNames.results,
                    builder: (context, state) => const ResultsPage(),
                  ),
                  GoRoute(
                    path: 'settings',
                    name: RouteNames.settings,
                    builder: (context, state) => const SettingsPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isBootstrapping = bootstrap.isLoading;

      if (isBootstrapping) {
        return location == '/splash' ? null : '/splash';
      }

      switch (authState.stage) {
        case AuthStage.unauthenticated:
          return location == '/login' ? null : '/login';
        case AuthStage.awaitingNationalId:
          return location == '/verify-national-id' ? null : '/verify-national-id';
        case AuthStage.authenticated:
          if (location == '/splash' ||
              location == '/login' ||
              location == '/verify-national-id') {
            return '/home';
          }
          return null;
      }
    },
  );
});
