// ignore_for_file: unused_import

import 'package:flutter/material.dart';

class SplashController {
  final BuildContext context;
  final TickerProvider vsync;

  late final AnimationController _logoController;
  late final Animation<double> logoOpacity;
  late final Animation<double> logoScale;

  final ValueNotifier<bool> showInitialScreen = ValueNotifier(true);
  final ValueNotifier<bool> showLogoScreen = ValueNotifier(false);

  SplashController({required this.context, required this.vsync}) {
    _logoController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1500),
    );

    logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
  }

  void startAnimation({required VoidCallback onComplete}) async {
    showLogoScreen.value = true;
    await _logoController.forward();
    await Future.delayed(const Duration(seconds: 2));
    onComplete();
  }

  void dispose() {
    _logoController.dispose();
    showInitialScreen.dispose();
    showLogoScreen.dispose();
  }
}
