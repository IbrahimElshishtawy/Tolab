import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
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
      child: StoreConnector<AppState, ThemeMode>(
        distinct: true,
        converter: (store) => store.state.settingsState.bundle.themeMode,
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'Tolab Admin',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: _router.router,
          );
        },
      ),
    );
  }
}
