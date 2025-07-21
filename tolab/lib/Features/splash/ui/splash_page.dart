// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:tolab/Features/splash/controllers/splash_controller.dart';

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
            Navigator.pushReplacementNamed(context, '/login');
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
          // شاشة البداية الثابتة
          ValueListenableBuilder<bool>(
            valueListenable: controller.showInitialScreen,
            builder: (_, showInitial, __) {
              return showInitial
                  ? AnimatedBuilder(
                      animation: controller.revealAnimation,
                      builder: (_, __) {
                        return ClipPath(
                          clipper: RevealClipper(
                            controller.revealAnimation.value,
                          ),
                          child: Container(
                            color: theme.primaryColor,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color.fromARGB(255, 2, 33, 235),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : const SizedBox();
            },
          ),

          // شاشة الشعار بالأنيميشن
          ValueListenableBuilder<bool>(
            valueListenable: controller.showLogoScreen,
            builder: (_, showLogo, __) {
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
                                errorBuilder: (_, e, __) =>
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
}

// ✅ ClipPath مخصص لتأثير الـ Circular Reveal
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
