// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';

import 'login_form.dart';

class LoginHeroCard extends StatefulWidget {
  final bool isLoading;

  const LoginHeroCard({super.key, required this.isLoading});

  @override
  State<LoginHeroCard> createState() => _LoginHeroCardState();
}

class _LoginHeroCardState extends State<LoginHeroCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );

    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Frosted Glass Card
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08), // شفافية الكارد
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25), // إطار خفيف
                      width: 1.2,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // عنوان
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            color: Colors.blueAccent.shade100,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Tolab Admin",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Text(
                        "تسجيل دخول المسؤول",
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color.fromARGB(
                            255,
                            255,
                            254,
                            254,
                          ).withOpacity(0.75),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login Form
                      LoginForm(isLoading: widget.isLoading),
                    ],
                  ),
                ),
              ),
            ),

            // Lottie Loading Overlay
            // if (widget.isLoading)
            //   Positioned.fill(
            //     child: Container(
            //       decoration: BoxDecoration(
            //         color: Colors.black.withOpacity(0.3),
            //         borderRadius: BorderRadius.circular(24),
            //       ),
            //       child: Center(
            //         child: Lottie.asset(
            //           'assets/lottiefiles/login_success.json',
            //           repeat: true,
            //         ),
            //       ),
            //     ),
          ],
        ),
      ),
    );
  }
}
