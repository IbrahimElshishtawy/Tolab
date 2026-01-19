import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:tolab_fci/redux/state/app_state.dart';
import 'router.dart';

class App extends StatelessWidget {
  final Store<AppState> store;

  const App({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        /// 🔹 Light Theme
        theme: ThemeData(
          brightness: Brightness.light,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),

        /// 🔹 Dark Theme
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        ),

        /// 🔹 يتبع إعدادات النظام تلقائيًا
        themeMode: ThemeMode.system,

        home: const AppRouter(),
      ),
    );
  }
}
