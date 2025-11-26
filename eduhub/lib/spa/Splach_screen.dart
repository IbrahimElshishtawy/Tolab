// ignore_for_file: file_names

import 'package:eduhub/router/app_routes..dart';
import 'package:flutter/material.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.forward();

    _goNext();
  }

  Future<void> _goNext() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(AppRoutes.studentDesktopHome);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1F),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // LOGO
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF22C55E), Color(0xFF3B82F6)],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: Offset(0, 10),
                        color: Colors.black45,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'T',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // BRAND TITLE
                const Text(
                  'TOLAB',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Smart College Platform',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: 160,
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    color: const Color(0xFF22C55E),
                    backgroundColor: Colors.white12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
