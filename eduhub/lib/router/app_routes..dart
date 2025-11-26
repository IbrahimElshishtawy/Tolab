import 'package:eduhub/spa/Splach_screen.dart';

import 'package:go_router/go_router.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: "/splash",
    routes: [
      GoRoute(
        path: "/splash",
        builder: (context, state) => const Splashscreen(),
      ),
    ],
  );
}
