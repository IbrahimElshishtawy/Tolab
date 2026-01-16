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
      theme: ThemeData(
        fontFamily: 'Cairo', // لو بتستخدم خط عربي
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
