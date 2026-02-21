import 'package:go_router/go_router.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/home/ui/home_screen.dart';
import '../../features/subjects/ui/subjects_screen.dart';
import '../../features/subjects/ui/subject_details_screen.dart';
import '../../features/calendar/ui/calendar_screen.dart';
import '../../features/community/ui/community_screen.dart';
import '../../features/profile/ui/profile_screen.dart';
import '../../features/tasks/ui/task_details_screen.dart';
import '../../features/tasks/data/models.dart';
import '../../features/subjects/data/models.dart';
import '../../features/subjects/ui/quiz_details_screen.dart';
import '../ui/widgets/app_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    // Basic auth guard - in a real app check token in store
    final bool _ = state.matchedLocation == '/login';
    // For now, assume unauthenticated if we're at /login and want to go elsewhere
    // This is simplified as we don't have easy access to Redux store here without extra setup
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
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
            ),
          ],
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: '/community',
          builder: (context, state) => const CommunityScreen(),
        ),
        GoRoute(
          path: '/tasks/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            final task = Task(
              id: id,
              title: 'Deep Linked Task',
              description: 'Description for $id',
              dueDate: DateTime.now(),
            );
            return TaskDetailsScreen(task: task, subjectId: 1);
          },
        ),
        GoRoute(
          path: '/quizzes/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            final quiz = Quiz(
              id: id,
              title: 'Deep Linked Quiz',
              subjectId: 1,
              startAt: DateTime.now(),
              endAt: DateTime.now(),
              durationMins: 30,
              totalPoints: 10,
            );
            return QuizDetailsScreen(quiz: quiz);
          },
        ),
        GoRoute(
          path: '/posts/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            final post = {
              'id': id,
              'user': 'User',
              'content': 'Deep linked post',
              'likes': 0,
              'comments_count': 0,
              'created_at': DateTime.now().toIso8601String(),
            };
            return PostDetailsScreen(post: post);
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);
