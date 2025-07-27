// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tolab/page/splash/controllers/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final SplashController controller;
  bool isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!isInitialized) {
      controller = SplashController(context: context, vsync: this);

      controller.startAnimation(
        onComplete: () {
          if (mounted) {
            checkLoginState();
          }
        },
      );

      isInitialized = true;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: controller.logoOpacity,
          child: ScaleTransition(
            scale: controller.logoScale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/image_splash/Tolab_splash_page.png',
                  width: 200,
                  height: 200,
                  errorBuilder: (_, e, _) =>
                      const Text("❌ لم يتم تحميل الصورة"),
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome to Tolab',
                  style: TextStyle(
                    fontSize: 20,
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> checkLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
