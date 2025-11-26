// ignore_for_file: deprecated_member_use, file_names

import 'package:eduhub/router/app_routes..dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashDesktop extends StatefulWidget {
  const SplashDesktop({super.key});

  @override
  State<SplashDesktop> createState() => _SplashDesktopState();
}

class _SplashDesktopState extends State<SplashDesktop>
    with TickerProviderStateMixin {
  bool _navigated = false;

  // Animation للـ Fade + Scale (الدخول)
  late final AnimationController _introController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  // Animation للـ Pulse Glow
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale; // يكبر/يصغر بسيط

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 0.96, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    // Backup timeout
    Future.delayed(const Duration(seconds: 6), _navigateIfNeeded);
  }

  void _navigateIfNeeded() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.pushReplacementNamed(context, AppRoutes.studentDesktopHome);
  }

  @override
  void dispose() {
    _introController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ========= FULL SCREEN LOTTIE BACKGROUND =========
          Positioned.fill(
            child: Lottie.asset(
              'assets/lottiefiles/Universo-header-latech.json',
              fit: BoxFit.cover,
              repeat: true,
              onLoaded: (composition) {
                Future.delayed(composition.duration * 0.95, _navigateIfNeeded);
              },
            ),
          ),

          // ========= CENTER CONTENT WITH ANIMATION =========
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ====== LOGO WITH PULSE GLOW ======
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final pulseValue = _pulseController.value;
                        return Transform.scale(
                          scale: _pulseScale.value,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(
                                    0.25 + 0.25 * pulseValue,
                                  ),
                                  blurRadius: 30 + 20 * pulseValue,
                                  spreadRadius: 3 + 2 * pulseValue,
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: child,
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/icons/logo.jpg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'EduHuB',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.8,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Smart College Platform',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: 240,
                      child: LinearProgressIndicator(
                        minHeight: 4,
                        color: const Color(0xFF22C55E),
                        backgroundColor: Colors.white24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
