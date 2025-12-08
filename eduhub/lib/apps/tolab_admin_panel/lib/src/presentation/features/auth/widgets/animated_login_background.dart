import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimatedLoginBackground extends StatelessWidget {
  const AnimatedLoginBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient أساسي للخلفية
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF141E30), Color(0xFF243B55)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Lottie Background (shapes / abstract)
        Positioned.fill(
          child: Opacity(
            opacity: 0.4,
            child: Lottie.asset(
              'assets/lottiefiles/login_bg.json',
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),
        ),

        // WiFi / Connectivity أنميشن في الزاوية
        Positioned(
          top: 40,
          right: 40,
          child: SizedBox(
            width: 80,
            height: 80,
            child: Lottie.asset(
              'assets/lottiefiles/login_wifi.json',
              repeat: true,
            ),
          ),
        ),

        // Blur overlay خفيف لإضفاء عمق
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.black.withOpacity(0.12)),
          ),
        ),
      ],
    );
  }
}
