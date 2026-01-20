import 'package:flutter/material.dart';
import 'package:tolab_fci/features/splash/presentation/widgets/Splash_Shapes_Painter.dart';

class SplashBackground extends StatelessWidget {
  final Widget child;

  const SplashBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
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
