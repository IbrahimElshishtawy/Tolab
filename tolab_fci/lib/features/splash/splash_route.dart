import 'package:flutter/material.dart';
import 'package:tolab_fci/features/splash/presentation/screens/splash_screen.dart';
import 'package:tolab_fci/features/splash/presentation/screens/intro_screen.dart';

class SplashRoute {
  /// Route Names
  static const String splash = '/';
  static const String intro = '/intro';

  /// Route Generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case intro:
        return MaterialPageRoute(
          builder: (_) => const IntroScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
    }
  }
}
