// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'splash_shapes_painter.dart';

class AdaptiveSplashBackground extends StatelessWidget {
  final Widget child;

  const AdaptiveSplashBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF023EC5) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
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
