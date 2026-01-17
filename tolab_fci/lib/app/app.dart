import 'package:flutter/material.dart';
import 'router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OLAB',

      // 🌙 Dark Mode فقط
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Cairo',
        scaffoldBackgroundColor: const Color(0xFF0B4DFF),
        useMaterial3: true,
      ),

      home: const AppRouter(),
    );
  }
}
