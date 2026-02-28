import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/auth/ui/forget_password_screen.dart';
import '../../features/auth/ui/verification_code_screen.dart';
import '../../features/auth/ui/reset_password_screen.dart';
import '../../features/home/ui/home_screen.dart';
import '../../features/subjects/presentation/screens/subjects_screen.dart';
import '../../features/subjects/presentation/screens/subject_details_screen.dart';
import '../../features/subjects/presentation/screens/lectures_screen.dart';
import '../../features/subjects/presentation/screens/sections_screen.dart';
import '../../features/subjects/presentation/screens/quizzes_screen.dart';
import '../../features/subjects/presentation/screens/tasks_screen.dart';
import '../../features/subjects/presentation/screens/summaries_screen.dart';
import '../../features/subjects/presentation/screens/add_summary_screen.dart';
import '../../features/calendar/ui/calendar_screen.dart';
import '../../features/community/ui/community_screen.dart';
import '../../features/notifications/ui/notifications_screen.dart';
import '../../features/more/presentation/screens/more_screen.dart';
import '../../features/more/presentation/screens/profile_screen.dart';
import '../../features/more/presentation/screens/academic_results_screen.dart';
import '../../features/more/presentation/screens/language_screen.dart';
import '../../features/more/presentation/screens/notification_settings_screen.dart';
import '../ui/widgets/app_scaffold.dart';
import '../ui/widgets/admin_shell.dart';
import '../../features/admin/presentation/screens/admin_users_screen.dart';
import '../../features/admin/presentation/screens/admin_subjects_screen.dart';
import '../../features/admin/presentation/screens/admin_offerings_screen.dart';
import '../../features/admin/presentation/screens/admin_content_screen.dart';
import '../../features/admin/presentation/screens/admin_schedule_screen.dart';
import '../../features/admin/presentation/screens/admin_moderation_screen.dart';
import '../../features/admin/presentation/screens/admin_broadcast_notifications_screen.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../redux/app_state.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final store = StoreProvider.of<AppState>(context);
    final authState = store.state.authState;
    final bool loggingIn = state.matchedLocation == '/login' ||
        state.matchedLocation == '/forget-password' ||
        state.matchedLocation == '/verify-code' ||
        state.matchedLocation == '/reset-password';

    if (!authState.isAuthenticated) {
      return loggingIn ? null : '/login';
    }

    if (loggingIn) {
      return authState.role == 'ADMIN' ? '/admin/users' : '/home';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/forget-password', builder: (context, state) => const ForgetPasswordScreen()),
    GoRoute(path: '/verify-code', builder: (context, state) => const VerificationCodeScreen()),
    GoRoute(path: '/reset-password', builder: (context, state) => const ResetPasswordScreen()),
    ShellRoute(
      builder: (context, state, child) {
        final store = StoreProvider.of<AppState>(context);
        if (store.state.authState.role == 'ADMIN') {
          return AdminShell(child: child);
        }
        return AppScaffold(child: child);
      },
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/subjects',
          builder: (context, state) => const SubjectsScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                final title = state.extra as String? ?? 'Subject Details';
                return SubjectDetailsScreen(subjectId: id, title: title);
              },
              routes: [
                GoRoute(path: 'lectures', builder: (context, state) => LecturesScreen(subjectId: int.parse(state.pathParameters['id']!))),
                GoRoute(path: 'sections', builder: (context, state) => SectionsScreen(subjectId: int.parse(state.pathParameters['id']!))),
                GoRoute(path: 'quizzes', builder: (context, state) => QuizzesScreen(subjectId: int.parse(state.pathParameters['id']!))),
                GoRoute(path: 'tasks', builder: (context, state) => TasksScreen(subjectId: int.parse(state.pathParameters['id']!))),
                GoRoute(
                  path: 'summaries',
                  builder: (context, state) => SummariesScreen(subjectId: int.parse(state.pathParameters['id']!)),
                  routes: [
                    GoRoute(path: 'add', builder: (context, state) => AddSummaryScreen(subjectId: int.parse(state.pathParameters['id']!))),
                  ],
                ),
              ],
            ),
          ],
        ),
        GoRoute(path: '/calendar', builder: (context, state) => const CalendarScreen()),
        GoRoute(path: '/community', builder: (context, state) => const CommunityScreen()),
        GoRoute(path: '/more', builder: (context, state) => const MoreScreen()),
        GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        GoRoute(path: '/results', builder: (context, state) => const AcademicResultsScreen()),
        GoRoute(path: '/language', builder: (context, state) => const LanguageScreen()),
        GoRoute(path: '/notification-settings', builder: (context, state) => const NotificationSettingsScreen()),

        // Admin Routes
        GoRoute(path: '/admin/users', builder: (context, state) => const AdminUsersScreen()),
        GoRoute(path: '/admin/subjects', builder: (context, state) => const AdminSubjectsScreen()),
        GoRoute(path: '/admin/offerings', builder: (context, state) => const AdminOfferingsScreen()),
        GoRoute(path: '/admin/content', builder: (context, state) => const AdminContentScreen()),
        GoRoute(path: '/admin/schedule', builder: (context, state) => const AdminScheduleScreen()),
        GoRoute(path: '/admin/moderation', builder: (context, state) => const AdminModerationScreen()),
        GoRoute(path: '/admin/broadcast', builder: (context, state) => const AdminBroadcastNotificationsScreen()),
      ],
    ),
  ],
);
