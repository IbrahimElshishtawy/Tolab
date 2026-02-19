// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'Splash_Shapes_Painter.dart';

class AdaptiveSplashBackground extends StatelessWidget {
  final Widget child;

  const AdaptiveSplashBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: SplashShapesPainter(isDark: isDark),
          ),
          child,
        ],
      ),
    );
  }
}
