import 'package:flutter/material.dart';
import 'package:tolab/page/auth/pages/forgot_password_page.dart';
import 'package:tolab/page/auth/pages/verify_email_page.dart';
import 'package:tolab/page/home/home_page.dart';
import 'package:tolab/page/auth/pages/login_page.dart';
import 'package:tolab/page/auth/pages/register_page.dart';
import 'package:tolab/page/profile/page/profile_page.dart';
import 'package:tolab/page/splash/page/splash_page.dart';
import 'package:tolab/page/auth/pages/set_new_password_page.dart';
import 'package:tolab/page/auth/pages/choose_role_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/choose-role':
        return MaterialPageRoute(builder: (_) => const ChooseRolePage());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
      case '/verify-code':
        return MaterialPageRoute(builder: (_) => const VerifyCodePage());
      case '/set-new-password':
        return MaterialPageRoute(builder: (_) => SetNewPasswordPage());
      case '/profile':
        return MaterialPageRoute(builder: (_) => ProfilePage());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('❌ Page not found'))),
        );
    }
  }
}
