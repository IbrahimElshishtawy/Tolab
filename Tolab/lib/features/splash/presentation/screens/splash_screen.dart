// ignore_for_file: unnecessary_underscores

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tolab_fci/features/splash/presentation/widgets/Tolab_Logo_Icon_write(T).dart';
import 'package:tolab_fci/features/splash/presentation/widgets/splash_background.dart';
import 'package:tolab_fci/features/splash/presentation/screens/intro_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), _goToIntro);
  }

  void _goToIntro() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (_, __, ___) => const IntroScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SplashBackground(
      child: Center(
        child: Hero(
          tag: 'tolab_logo',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
      ),
    );
  }
}
