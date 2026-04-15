import 'package:flutter/material.dart';

import '../app_admin/core/theme/app_theme.dart';
import 'bootstrap/app_bootstrap.dart';
import 'core/app_scope.dart';
import 'localization/app_localizations.dart';
import 'localization/locale_controller.dart';
import 'routing/app_router.dart';

class TolabApp extends StatefulWidget {
  const TolabApp({super.key, required this.bootstrap});

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
    final listenables = Listenable.merge(<Listenable>[
      widget.bootstrap.themeController,
      widget.bootstrap.localeController,
    ]);

    return AppScope(
      bootstrap: widget.bootstrap,
      child: AnimatedBuilder(
        animation: listenables,
        builder: (context, _) {
          return MaterialApp.router(
            onGenerateTitle: (context) => context.l10n.t('common.app_name'),
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: widget.bootstrap.themeController.themeMode,
            locale: widget.bootstrap.localeController.locale,
            supportedLocales: LocaleController.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            routerConfig: _router.router,
          );
        },
      ),
    );
  }
}
