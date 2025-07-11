import 'package:flutter/material.dart';
import 'package:tolab/Features/home/home_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // case '/':
      //   return MaterialPageRoute(builder: (_) => const SplashScreen());
      // case '/login':
      //   return MaterialPageRoute(builder: (_) => const LoginPage());
      // case '/register':
      //   return MaterialPageRoute(builder: (_) => const RegisterPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());

      // Add more routes here as needed
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('❌ Page not found'))),
        );
    }
  }
}
