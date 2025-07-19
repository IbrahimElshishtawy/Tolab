// ignore_for_file: avoid_print, unnecessary_underscores, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:tolab/Features/splash/controllers/splash_controller.dart';

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
    final theme = Theme.of(context);

    if (!controller.isInitialized) {
      return const Scaffold(body: SizedBox());
    }

    return Scaffold(
      body: Stack(
        children: [
          // خلفية بلون الخلفية من الثيم
          Container(color: theme.scaffoldBackgroundColor),

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
                              Text(
                                'Welcome to Tolab',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: theme.textTheme.bodyLarge?.color
                                      ?.withOpacity(0.7),
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

          // دائرة تغطّي الشعار بلون خلفية الثيم
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
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
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
