import 'dart:ui';

import 'package:eduhub/router/app_routes..dart';
import 'package:flutter/material.dart';

void main() {
  runApp(EduHubApp());
}

class EduHubApp extends StatelessWidget {
  const EduHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EduHub',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRoutes.router,
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const _AppScrollBehavior(),
          child: child!,
        );
      },
    );
  }
}

class _AppScrollBehavior extends ScrollBehavior {
  const _AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}
