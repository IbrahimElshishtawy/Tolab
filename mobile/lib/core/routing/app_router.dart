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

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/forget-password', builder: (context, state) => const ForgetPasswordScreen()),
    GoRoute(path: '/verify-code', builder: (context, state) => const VerificationCodeScreen()),
    GoRoute(path: '/reset-password', builder: (context, state) => const ResetPasswordScreen()),
    ShellRoute(
      builder: (context, state, child) => AppScaffold(child: child),
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
      ],
    ),
  ],
);
