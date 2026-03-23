import 'package:flutter/material.dart';

class RevealUp extends StatelessWidget {
  const RevealUp({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      child: child,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 24),
          child: Opacity(opacity: value, child: child),
        );
      },
    );
  }
}
