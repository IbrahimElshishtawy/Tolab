import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:tolab_fci/core/theme/app_theme.dart';
import 'package:tolab_fci/features/home/presentation/screens/student_home_screen.dart';
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
        theme: AppTheme.light,

        /// 🔹 Dark Theme
        darkTheme: AppTheme.dark,

        /// 🔹 يتبع إعدادات النظام تلقائيًا
        themeMode: ThemeMode.system,

        home: const StudentHomeScreen(),
        // const AppRouter(),
      ),
    );
  }
}
