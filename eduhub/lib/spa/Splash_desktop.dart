import 'package:eduhub/router/app_routes..dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashDesktop extends StatefulWidget {
  const SplashDesktop({super.key});

  @override
  State<SplashDesktop> createState() => _SplashDesktopState();
}

class _SplashDesktopState extends State<SplashDesktop> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), _navigateIfNeeded);
  }

  void _navigateIfNeeded() {
    if (_navigated || !mounted) return;

    _navigated = true;
    Navigator.of(context).pushReplacementNamed(AppRoutes.studentDesktopHome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ========== LOTTIE ANIMATION ==========
            SizedBox(
              width: 260,
              height: 260,
              child: Lottie.asset(
                'assets/lottie/tolab_desktop_splash.json',
                onLoaded: (composition) {
                  Future.delayed(composition.duration * 0.9, _navigateIfNeeded);
                },
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'TOLAB DESKTOP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Smart College Platform',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                minHeight: 3,
                color: const Color(0xFF22C55E),
                backgroundColor: Colors.white10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
