// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:tolab/Features/auth/pages/forgot_password_page.dart';
import 'package:tolab/Features/home/home_page.dart';

import 'package:tolab/Features/auth/pages/login_page.dart';
import 'package:tolab/Features/auth/pages/register_page.dart';
import 'package:tolab/Features/splash/ui/splash_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('❌ Page not found'))),
        );
    }
  }
}
