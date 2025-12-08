// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimatedLoginBackground extends StatelessWidget {
  const AnimatedLoginBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF141E30), Color(0xFF243B55)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        //background
        Positioned.fill(
          child: Opacity(
            opacity: 0.3,
            child: Lottie.asset(
              'assets/lottiefiles/login_bg.json',
              fit: BoxFit.scaleDown,
              repeat: true,
            ),
          ),
        ),
        // icon effection
        Positioned(
          top: 40,
          right: 40,
          child: SizedBox(
            width: 250,
            height: 250,
            child: Lottie.asset(
              'assets/lottiefiles/login_wifi.json',
              repeat: true,
            ),
          ),
        ),

        // Blur overlay
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(color: Colors.black.withOpacity(0.12)),
          ),
        ),
      ],
    );
  }
}
