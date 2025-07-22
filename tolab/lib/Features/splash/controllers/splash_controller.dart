// ignore_for_file: unused_import

import 'package:flutter/material.dart';

class SplashController {
  final BuildContext context;
  final TickerProvider vsync;

  // متغيرات الأنيميشن
  late final AnimationController _revealController;
  late final Animation<double> revealAnimation;

  late final AnimationController _logoController;
  late final Animation<double> logoOpacity;
  late final Animation<double> logoScale;

  // ValueNotifiers للتحكم في الشاشة
  final ValueNotifier<bool> showInitialScreen = ValueNotifier(true);
  final ValueNotifier<bool> showLogoScreen = ValueNotifier(false);

  SplashController({required this.context, required this.vsync}) {
    // أنيميشن الكشف الدائري
    _revealController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 2),
    );

    revealAnimation =
        Tween<double>(
          begin: 0.0,
          end: MediaQuery.of(context).size.longestSide * 1.2,
        ).animate(
          CurvedAnimation(parent: _revealController, curve: Curves.easeOut),
        );

    // أنيميشن الشعار
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
    // أول حاجة نبدأ بالكشف الدائري
    await _revealController.forward();
    showInitialScreen.value = false;

    // نعرض شاشة الشعار
    showLogoScreen.value = true;
    await _logoController.forward();

    // بعد الانتظار ننتقل للصفحة التالية
    await Future.delayed(const Duration(seconds: 2));
    onComplete();
  }

  void dispose() {
    _revealController.dispose();
    _logoController.dispose();
    showInitialScreen.dispose();
    showLogoScreen.dispose();
  }
}
