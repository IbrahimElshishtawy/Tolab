import 'package:flutter/material.dart';
import 'package:tolab_fci/features/splash/presentation/widgets/Tolab_Logo_Icon_write(T).dart';
import 'package:tolab_fci/features/splash/presentation/widgets/adaptive_splash_background.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AdaptiveSplashBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Spacer(flex: 4),

              Align(
                alignment: Alignment.topRight,
                child: Hero(
                  tag: 'tolab_logo',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TolabLogoBox(),
                      const SizedBox(width: 7),
                      Text(
                        'OLAB',
                        style: TextStyle(
                          fontSize: 24,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF023EC5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 10),

              Text(
                'نظم.\nتواصل.\nتعلم.',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 36,
                  height: 1.4,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF023EC5),
                ),
              ),

              const Spacer(flex: 10),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ابدأ من هنا',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF023EC5),
                  ),
                ),
              ),

              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
    );
  }
}
