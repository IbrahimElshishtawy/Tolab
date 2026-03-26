import 'package:flutter/material.dart';

import '../../../core/colors/app_colors.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.pageGlow),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FlutterLogo(size: 72),
              SizedBox(height: 20),
              Text('Tolab Admin'),
              SizedBox(height: 16),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
