import 'package:flutter/material.dart';
import 'package:tolab_fci/features/splash/presentation/widgets/Tolab_Logo_Icon_write(T).dart';
import 'package:tolab_fci/features/splash/presentation/widgets/splash_background.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SplashBackground(
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔲 White square with rotated T
            TolabLogoBox(),
            const SizedBox(width: 7),

            const Text(
              'OLAB',
              style: TextStyle(
                fontSize: 28,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
