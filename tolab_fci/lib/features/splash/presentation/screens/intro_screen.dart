import 'package:flutter/material.dart';
import 'package:tolab_fci/features/splash/presentation/widgets/adaptive_splash_background.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveSplashBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Spacer(flex: 2),

              Text(
                'نظم.\nتواصل.\nتعلم.',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 36,
                  height: 1.4,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF023EC5),
                ),
              ),

              const Spacer(),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ابدأ من هنا',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF023EC5),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
