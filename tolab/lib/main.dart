import 'package:flutter/material.dart';
import 'package:tolab/Features/settings/app_theme.dart';
import 'package:tolab/routes/app_router.dart';

void main() {
  runApp(const TolabApp());
}

class TolabApp extends StatelessWidget {
  const TolabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system, // يمكن تغييره من الإعدادات لاحقًا
      initialRoute: '/splash',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
