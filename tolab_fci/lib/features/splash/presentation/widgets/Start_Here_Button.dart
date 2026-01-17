import 'package:flutter/material.dart';
import 'package:tolab_fci/features/auth/presentation/screens/login_screen.dart';

class StartHereButton extends StatelessWidget {
  final bool isDark;

  const StartHereButton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _navigateToLogin(context);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ابدأ من هنا',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF023EC5),
            ),
          ),
          const SizedBox(width: 12),
          Transform.rotate(
            angle: -0.75,
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 26,
              color: isDark ? Colors.white : const Color(0xFF023EC5),
            ),
          ),
        ],
      ),
    );
  }
}

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
