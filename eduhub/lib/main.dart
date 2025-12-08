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

import 'package:eduhub/apps/tolab_admin_panel/lib/src/presentation/features/auth/pages/login_page.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/app_state.dart';
import 'package:eduhub/apps/tolab_admin_panel/lib/src/state/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

void main() {
  final Store<AppState> store = createStore();

  runApp(TolabAdminApp(store: store));
}

class TolabAdminApp extends StatelessWidget {
  final Store<AppState> store;

  const TolabAdminApp({required this.store, super.key});

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: store,
      child: MaterialApp(
        title: "Tolab Admin Panel",
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      ),
    );
  }
}
