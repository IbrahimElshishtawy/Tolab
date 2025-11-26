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
    // Backup timeout
    Future.delayed(const Duration(seconds: 6), _navigateIfNeeded);
  }

  void _navigateIfNeeded() {
    if (_navigated || !mounted) return;

    _navigated = true;
    Navigator.pushReplacementNamed(context, AppRoutes.studentDesktopHome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // لو اللوتي شفاف
      body: Stack(
        children: [
          // ===== FULL SCREEN LOTTIE ANIMATION =====
          Positioned.fill(
            child: Lottie.asset(
              'assets/lottiefiles/Universo-header-latech.json',
              fit: BoxFit.cover,
              onLoaded: (composition) {
                // ننتقل عندما تقترب الأنيميشن من الانتهاء
                Future.delayed(composition.duration * 0.95, _navigateIfNeeded);
              },
            ),
          ),

          // ===== OVERLAY CONTENT (center logo + texts) =====
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo Image
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black87,
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/icons/iconapp.jpg',
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'TOLAB DESKTOP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Smart College Platform',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),

                const SizedBox(height: 20),

                // Progress bar
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    color: Color(0xFF22C55E),
                    backgroundColor: Colors.white24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
