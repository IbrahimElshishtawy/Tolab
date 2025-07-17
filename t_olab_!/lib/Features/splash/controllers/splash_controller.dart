import 'package:flutter/material.dart';

class SplashController {
  final BuildContext context;
  final TickerProvider vsync;

  late final AnimationController bgCircleController;
  late final AnimationController logoController;
  late final AnimationController logoHideController;

  late final Animation<double> circleScale;
  late final Animation<double> logoOpacity;
  late final Animation<double> logoScale;
  late final Animation<double> logoHideScale;

  ValueNotifier<bool> showLogoScreen = ValueNotifier(false);
  ValueNotifier<bool> hideLogoWithCircle = ValueNotifier(false);

  bool isInitialized = false;
  final Color splashColor = const Color.fromRGBO(152, 172, 201, 1);

  SplashController({required this.vsync, required this.context});

  void startAnimation() async {
    final size = MediaQuery.of(context).size;
    final maxSize = size.longestSide * 2;
    final scaleBegin = maxSize / size.width;

    bgCircleController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1500),
    );
    circleScale = Tween<double>(begin: scaleBegin, end: 0).animate(
      CurvedAnimation(parent: bgCircleController, curve: Curves.easeInOut),
    );

    logoController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 800),
    );
    logoOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: logoController, curve: Curves.easeIn));
    logoScale = Tween<double>(begin: 1.2, end: 1).animate(
      CurvedAnimation(parent: logoController, curve: Curves.easeOutBack),
    );

    logoHideController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1000),
    );
    logoHideScale = Tween<double>(begin: 0.0, end: scaleBegin).animate(
      CurvedAnimation(parent: logoHideController, curve: Curves.easeInOut),
    );

    isInitialized = true;

    bgCircleController.forward();

    bgCircleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        showLogoScreen.value = true;
        logoController.forward();

        Future.delayed(const Duration(seconds: 2), () {
          hideLogoWithCircle.value = true;
          logoHideController.forward();

          logoHideController.addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          });
        });
      }
    });
  }

  void dispose() {
    if (!isInitialized) return;
    bgCircleController.dispose();
    logoController.dispose();
    logoHideController.dispose();
  }
}
