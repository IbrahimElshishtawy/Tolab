// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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
            // Card أساسي
            Card(
              elevation: 16,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
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
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "تسجيل دخول المسؤول",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // فورم
                    LoginForm(isLoading: widget.isLoading),
                  ],
                ),
              ),
            ),

            // Lottie success overlay (اختياري – مثلاً عند الإرسال)
            if (widget.isLoading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Lottie.asset(
                      'assets/lottiefiles/login_success.json',
                      repeat: true,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
