// ignore_for_file: deprecated_member_use, file_names

import 'package:eduhub/router/app_routes.dart';
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

  late final AnimationController _introController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();

    // Intro animation
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
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

    // Pulse scale only (بدون شادو)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Backup timeout
    Future.delayed(const Duration(seconds: 6), _navigateIfNeeded);
  }

  void _navigateIfNeeded() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.pushReplacementNamed(context, AppRoutes.login_dashboard);
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
          // ========= FULLSCREEN LOTTIE BACKGROUND =========
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

          // ========= MAIN CONTENT =========
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ====== MAIN LOADING LOTTIE (بدون شادو) ======
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseScale.value,
                          child: SizedBox(
                            width: 200,
                            height: 200,
                            child: child,
                          ),
                        );
                      },
                      child: Lottie.asset(
                        'assets/lottiefiles/Loading.json',
                        fit: BoxFit.contain,
                        repeat: true,
                      ),
                    ),

                    const SizedBox(height: 14),

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
