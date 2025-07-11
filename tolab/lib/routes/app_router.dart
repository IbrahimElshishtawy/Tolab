import 'package:flutter/material.dart';
import 'package:tolab/Features/home/home_page.dart';
import 'package:tolab/Features/Splash/splash_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('❌ Page not found'))),
        );
    }
  }
}
