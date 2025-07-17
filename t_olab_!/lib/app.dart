// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:tolab/routes/app_router.dart';

class ToLabApp extends StatelessWidget {
  const ToLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToLab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Cairo',
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/splash',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
