import 'package:flutter/material.dart';
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_outward_rounded,
                color: Color(0xFF0B4DFF),
                size: 28,
              ),
            ),
            const SizedBox(width: 10),
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
