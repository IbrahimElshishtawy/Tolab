// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:tolab/Features/Splash/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late SplashController controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ignore:
    print("🚀 محاولة تحميل الصورة: assets/image_splash/Tolab_splash_page.png");

    controller = SplashController(vsync: this, context: context);
    controller.startAnimation();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxSize = size.longestSide * 2;

    if (!controller.isInitialized) {
      return const Scaffold(body: SizedBox());
    }

    return Scaffold(
      body: Stack(
        children: [
          // خلفية بيضاء
          Container(color: Colors.white),

          // الدائرة الملونة التي تختفي تدريجيًا
          ValueListenableBuilder<bool>(
            valueListenable: controller.showLogoScreen,
            builder: (_, showLogo, __) {
              return !showLogo
                  ? Center(
                      child: AnimatedBuilder(
                        animation: controller.bgCircleController,
                        builder: (_, __) => Transform.scale(
                          scale: controller.circleScale.value,
                          child: Container(
                            width: maxSize,
                            height: maxSize,
                            decoration: BoxDecoration(
                              color: controller.splashColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox();
            },
          ),

          // الشعار يظهر تدريجيًا
          ValueListenableBuilder<bool>(
            valueListenable: controller.hideLogoWithCircle,
            builder: (_, hideLogo, __) {
              return ValueListenableBuilder<bool>(
                valueListenable: controller.showLogoScreen,
                builder: (_, showLogo, __) {
                  if (showLogo && !hideLogo) {
                    return Center(
                      child: FadeTransition(
                        opacity: controller.logoOpacity,
                        child: ScaleTransition(
                          scale: controller.logoScale,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/image_splash/Tolab_splash_page.png',
                                width: 250,
                                height: 250,
                                errorBuilder: (context, error, stackTrace) {
                                  print("❌ خطأ في تحميل الصورة: $error");
                                  return const Text("❌ لم يتم تحميل الصورة");
                                },
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Welcome to Tolab',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              );
            },
          ),

          // دائرة بيضاء تخفي الشعار
          ValueListenableBuilder<bool>(
            valueListenable: controller.hideLogoWithCircle,
            builder: (_, hideLogo, __) {
              return hideLogo
                  ? Center(
                      child: AnimatedBuilder(
                        animation: controller.logoHideController,
                        builder: (_, __) => Transform.scale(
                          scale: controller.logoHideScale.value,
                          child: Container(
                            width: maxSize,
                            height: maxSize,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
