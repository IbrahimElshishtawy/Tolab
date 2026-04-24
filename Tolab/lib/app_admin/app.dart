import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../app/localization/app_localizations.dart';
import '../app/localization/current_locale_state.dart';
import '../app/localization/locale_controller.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'modules/notifications/presentation/widgets/notification_toast_host.dart';
import 'shared/models/settings_models.dart';
import 'state/app_state.dart';

class TolabAdminApp extends StatefulWidget {
  const TolabAdminApp({super.key, required this.store});

  final Store<AppState> store;

  @override
  State<TolabAdminApp> createState() => _TolabAdminAppState();
}

class _TolabAdminAppState extends State<TolabAdminApp> {
  late final AppRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter(widget.store);
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: widget.store,
      child: StoreConnector<AppState, SettingsBundle>(
        distinct: true,
        converter: (store) => store.state.settingsState.bundle,
        builder: (context, bundle) {
          final languageCode = LocaleController.normalizeLanguageCode(
            bundle.localeCode,
          );
          CurrentLocaleState.update(languageCode);
          return MaterialApp.router(
            title: 'Tolab Admin',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(
              primaryColor: bundle.theme.primaryColor,
              secondaryColor: bundle.theme.secondaryColor,
            ),
            darkTheme: AppTheme.darkTheme(
              primaryColor: bundle.theme.primaryColor,
              secondaryColor: bundle.theme.secondaryColor,
            ),
            themeMode: bundle.themeMode,
            locale: Locale(languageCode),
            supportedLocales: LocaleController.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            routerConfig: _router.router,
            builder: (context, child) {
              return Stack(
                children: [
                  if (child != null) child,
                  const NotificationToastHost(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
