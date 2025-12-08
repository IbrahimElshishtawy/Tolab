import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoginSubmitButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const LoginSubmitButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<LoginSubmitButton> createState() => _LoginSubmitButtonState();
}

class _LoginSubmitButtonState extends State<LoginSubmitButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _widthAnimation = Tween<double>(
      begin: 1.0,
      end: 0.35, // shrink size when loading
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant LoginSubmitButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isLoading && !oldWidget.isLoading) {
      _controller.forward();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double maxWidth = 260;

    return AnimatedBuilder(
      animation: _widthAnimation,
      builder: (context, child) {
        final width = maxWidth * _widthAnimation.value;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: width,
          height: 52,
          curve: Curves.easeOut,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent.shade400,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            child: widget.isLoading
                ? SizedBox(
                    width: 55,
                    height: 55,
                    child: Lottie.asset(
                      "assets/lottiefiles/loding_bottom.json",
                      fit: BoxFit.contain,
                    ),
                  )
                : const Text(
                    "تسجيل الدخول",
                    style: TextStyle(
                      fontSize: 17,
                      letterSpacing: 0.8,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
