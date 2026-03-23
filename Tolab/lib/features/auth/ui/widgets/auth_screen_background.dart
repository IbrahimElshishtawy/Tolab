import 'package:flutter/material.dart';

class AuthBackgroundBubble {
  final double size;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final List<Color> colors;

  const AuthBackgroundBubble({
    required this.size,
    required this.colors,
    this.top,
    this.right,
    this.bottom,
    this.left,
  });
}

class AuthScreenBackground extends StatelessWidget {
  final Widget child;
  final List<AuthBackgroundBubble> bubbles;

  const AuthScreenBackground({
    super.key,
    required this.child,
    required this.bubbles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF4F8FF), Color(0xFFEAF1FF), Color(0xFFF9FBFF)],
        ),
      ),
      child: Stack(
        children: [
          for (final bubble in bubbles)
            Positioned(
              top: bubble.top,
              right: bubble.right,
              bottom: bubble.bottom,
              left: bubble.left,
              child: _AuthGlowBubble(
                size: bubble.size,
                colors: bubble.colors,
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class _AuthGlowBubble extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _AuthGlowBubble({
    required this.size,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: colors),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: 0.18),
              blurRadius: 48,
              spreadRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}
