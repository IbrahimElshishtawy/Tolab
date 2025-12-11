// // lib/main.dart
// import 'package:eduhub/router/app_routes..dart';
// import 'package:flutter/material.dart';

// void main() {
//   runApp(const TolabApp());
// }

// class TolabApp extends StatelessWidget {
//   const TolabApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Tolab',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color.fromARGB(255, 34, 50, 197),
//           brightness: Brightness.dark,
//         ),
//         useMaterial3: true,
//         scaffoldBackgroundColor: const Color(0xFF020617),
//         fontFamily: 'Roboto',
//       ),
//       initialRoute: AppRoutes.splash,
//       onGenerateRoute: AppRouter.onGenerateRoute,
//     );
//   }
// }
// ignore_for_file: non_constant_identifier_names
import 'package:eduhub/apps/tolab_admin_panel/lib/src/core/api/Api_Service_auth.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/core/api/Api_Service_dashhoard.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/app_state.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/auth/auth_middleware.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/dashboard/dashboard_middleware.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/reducers/app_reducer.dart';
import 'package:eduhub/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class TolabAdminApp extends StatelessWidget {
  final Store<AppState> store;

  const TolabAdminApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Tolab Admin Panel",

        // Important: use app routing system
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
        theme: ThemeData(
          fontFamily: "Cairo",
          scaffoldBackgroundColor: const Color(0xFF0F172A),
        ),
      ),
    );
  }
}

void main() {
  final auth = ApiServiceAuth();
  final Dashhoard = ApiServiceDashboard();
  final store = Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
    middleware: [...authMiddleware(auth), ...dashboardMiddleware(Dashhoard)],
  );

  runApp(TolabAdminApp(store: store));
}
