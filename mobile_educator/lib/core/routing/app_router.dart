import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/subjects/presentation/subjects_screen.dart';
import '../../features/subjects/presentation/subject_details_screen.dart';
import '../../features/community/presentation/community_screen.dart';
import '../../features/home/presentation/schedule_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/more/presentation/profile_screen.dart';
import '../widgets/app_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/subjects', builder: (context, state) => const SubjectsScreen()),
        GoRoute(
          path: '/subjects/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            final name = state.queryParameters['name'] ?? 'Subject';
            return SubjectDetailsScreen(subjectId: id, subjectName: name);
          },
        ),
        GoRoute(path: '/schedule', builder: (context, state) => const ScheduleScreen()),
        GoRoute(path: '/community', builder: (context, state) => const CommunityScreen()),
        GoRoute(path: '/more', builder: (context, state) => const MoreScreen()),
        GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      ],
    ),
  ],
);
