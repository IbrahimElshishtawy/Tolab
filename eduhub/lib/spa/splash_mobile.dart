// ignore_for_file: file_names

import 'package:eduhub/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashMobile extends StatefulWidget {
  const SplashMobile({super.key});

  @override
  State<SplashMobile> createState() => _SplashMobileState();
}

class _SplashMobileState extends State<SplashMobile>
    with SingleTickerProviderStateMixin {
  bool _navigated = false;

  late final AnimationController _introController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutBack,
    );

    _introController.forward();

    // Backup timeout
    Future.delayed(const Duration(seconds: 5), _navigateIfNeeded);
  }

  void _navigateIfNeeded() {
    if (_navigated || !mounted) return;

    _navigated = true;

    //Navigator.pushReplacementNamed(context, AppRoutes.);
  }

  @override
  void dispose() {
    _introController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // خلفية جradient خفيفة + ممكن تغيّر للألوان اللي تحبها
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF020617), Color(0xFF0B1120), Color(0xFF020617)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // (اختياري) لو حابب نفس خلفية الديسكتوب:
            // Positioned.fill(
            //   child: Opacity(
            //     opacity: 0.35,
            //     child: Lottie.asset(
            //       'assets/lottiefiles/Universo-header-latech.json',
            //       fit: BoxFit.cover,
            //       repeat: true,
            //     ),
            //   ),
            // ),
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // لوتي الـ Loading في النص
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: Lottie.asset(
                          'assets/lottiefiles/Loading.json',
                          fit: BoxFit.contain,
                          repeat: true,
                          onLoaded: (composition) {
                            // نضمن الانتقال بعد فترة قريبة من انتهاء الأنيميشن
                            Future.delayed(
                              composition.duration * 0.9,
                              _navigateIfNeeded,
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'EduHuB',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.4,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Smart College Platform',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ممكن تحط نسخة التطبيق / شعار صغير تحت
            const Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '© 2025 EduHuB',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
