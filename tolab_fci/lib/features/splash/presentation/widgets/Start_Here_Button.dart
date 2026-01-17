// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:tolab_fci/features/auth/presentation/screens/login_screen.dart';

class StartHereButton extends StatefulWidget {
  final bool isDark;

  const StartHereButton({super.key, required this.isDark});

  @override
  State<StartHereButton> createState() => _StartHereButtonState();
}

class _StartHereButtonState extends State<StartHereButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulse = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _slide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.08, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isDark ? Colors.white : const Color(0xFF023EC5);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _navigateToLogin(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔹 Text
            Text(
              'ابدأ من هنا',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.4,
              ),
            ),

            const SizedBox(width: 1),

            // 🔹 Animated Arrow
            SlideTransition(
              position: _slide,
              child: ScaleTransition(
                scale: _pulse,
                child: Transform.rotate(
                  angle: -0.55,
                  child: Icon(
                    Icons.trending_flat_rounded,
                    size: 30,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// Navigation with animation
/// ===============================
void _navigateToLogin(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 650),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const LoginScreen();
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation =
            Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutExpo),
            );

        final fadeAnimation = Tween<double>(
          begin: 0,
          end: 1,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    ),
  );
}
