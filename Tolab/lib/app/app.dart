import 'package:flutter/material.dart';

import '../app_admin/core/theme/app_theme.dart';
import 'bootstrap/app_bootstrap.dart';
import 'core/app_scope.dart';
import 'routing/app_router.dart';

class TolabApp extends StatefulWidget {
  const TolabApp({
    super.key,
    required this.bootstrap,
  });

  final UnifiedAppBootstrap bootstrap;

  @override
  State<TolabApp> createState() => _TolabAppState();
}

class _TolabAppState extends State<TolabApp> {
  late final UnifiedAppRouter _router;

  @override
  void initState() {
    super.initState();
    _router = UnifiedAppRouter(widget.bootstrap.authController);
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      bootstrap: widget.bootstrap,
      child: AnimatedBuilder(
        animation: widget.bootstrap.themeController,
        builder: (context, _) {
          return MaterialApp.router(
            title: 'Tolab University',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: widget.bootstrap.themeController.themeMode,
            routerConfig: _router.router,
          );
        },
      ),
    );
  }
}
