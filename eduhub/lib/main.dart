// lib/main.dart
import 'package:eduhub/router/app_routes..dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const TolabApp());
}

class TolabApp extends StatelessWidget {
  const TolabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tolab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 34, 50, 197),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF020617),
        fontFamily: 'Roboto',
      ),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
