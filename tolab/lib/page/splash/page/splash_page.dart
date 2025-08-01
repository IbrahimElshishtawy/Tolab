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
      body: Stack(
        children: [
          // شاشة الشعار بالأنيميشن
          ValueListenableBuilder<bool>(
            valueListenable: controller.showLogoScreen,
            builder: (_, showLogo, _) {
              return showLogo
                  ? Center(
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
                                  color: theme.textTheme.bodyLarge?.color
                                      ?.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox();
            },
          ),
        ],
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

// Custom clipper for the reveal animation
class RevealClipper extends CustomClipper<Path> {
  final double radius;

  RevealClipper(this.radius);

  @override
  Path getClip(Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    path.addOval(Rect.fromCircle(center: center, radius: radius));
    return path;
  }

  @override
  bool shouldReclip(covariant RevealClipper oldClipper) =>
      oldClipper.radius != radius;
}
