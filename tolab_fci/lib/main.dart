import 'package:flutter/material.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OLAB',

      // 🌞 Light Theme
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Cairo',
        useMaterial3: true,
      ),

      // 🌙 Dark Theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Cairo',
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,

      home: const SplashScreen(),
    );
  }
}
