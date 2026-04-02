import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'core/navigation/app_router.dart';
import 'core/services/app_dependencies.dart';
import 'core/theme/app_theme.dart';
import 'state/app_state.dart';

class DoctorAssistantApp extends StatelessWidget {
  const DoctorAssistantApp({
    super.key,
    required this.store,
    required this.dependencies,
  });

  final Store<DoctorAssistantAppState> store;
  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return StoreProvider<DoctorAssistantAppState>(
      store: store,
      child: Builder(
        builder: (context) {
          final router = createAppRouter(store);

          return MaterialApp.router(
            title: 'Tolab University',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: ThemeMode.system,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
