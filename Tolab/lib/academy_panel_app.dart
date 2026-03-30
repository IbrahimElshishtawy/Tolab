import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'app/modules/academy_panel/routing/academy_router.dart';
import 'app/modules/academy_panel/state/academy_state.dart';
import 'app/modules/academy_panel/widgets/toast_host.dart';
import 'app/core/theme/app_theme.dart';

class AcademyPanelApp extends StatefulWidget {
  const AcademyPanelApp({super.key, required this.store});

  final Store<AcademyAppState> store;

  @override
  State<AcademyPanelApp> createState() => _AcademyPanelAppState();
}

class _AcademyPanelAppState extends State<AcademyPanelApp> {
  late final AcademyRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AcademyRouter(widget.store);
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AcademyAppState>(
      store: widget.store,
      child: StoreConnector<AcademyAppState, ThemeMode>(
        distinct: true,
        converter: (store) => store.state.themeMode,
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'Tolab Academy Panel',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeMode,
            routerConfig: _router.router,
            builder: (context, child) {
              return Stack(
                children: [if (child != null) child, const AcademyToastHost()],
              );
            },
          );
        },
      ),
    );
  }
}
