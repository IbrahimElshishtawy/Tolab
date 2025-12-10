import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoginSubmitButton extends StatefulWidget {
  final bool isLoading;
  final bool isSuccess;
  final VoidCallback onPressed;

  const LoginSubmitButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.isSuccess,
  });

  @override
  State<LoginSubmitButton> createState() => _LoginSubmitButtonState();
}

class _LoginSubmitButtonState extends State<LoginSubmitButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;

  bool showSuccess = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _widthAnimation = Tween<double>(
      begin: 1.0,
      end: 0.30, // shrink size when loading
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(LoginSubmitButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // FAILED → IDLE
    if (!widget.isLoading && !widget.isSuccess) {
      _controller.reverse();
      showSuccess = false;
    }

    // LOADING → SHRINK
    if (widget.isLoading && !oldWidget.isLoading) {
      _controller.forward();
    }

    // LOADING FINISHED → SUCCESS
    if (widget.isSuccess && !oldWidget.isSuccess) {
      Future.delayed(const Duration(milliseconds: 250), () {
        setState(() {
          showSuccess = true;
        });

        // Reset success icon after a short moment
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              showSuccess = false;
            });
          }
        });
      });
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
          height: 54,
          curve: Curves.easeOut,
          child: ElevatedButton(
            onPressed: (widget.isLoading || widget.isSuccess)
                ? null
                : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent.shade400,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),

            // -------------------------
            // BUTTON CHILD STATE MACHINE
            // -------------------------
            child: _buildButtonChild(),
          ),
        );
      },
    );
  }

  Widget _buildButtonChild() {
    //  SUCCESS
    // if (showSuccess) {
    //   return Lottie.asset(
    //     "assets/lottiefiles/success_check.json",
    //     width: 55,
    //     height: 55,
    //     fit: BoxFit.contain,
    //   );
    // }

    // LOADING ANIMATION
    if (widget.isLoading) {
      return Lottie.asset(
        "assets/lottiefiles/loding_bottom.json",
        width: 55,
        height: 55,
        fit: BoxFit.contain,
      );
    }

    // IDLE STATE
    return const Text(
      "تسجيل الدخول",
      style: TextStyle(
        fontSize: 17,
        letterSpacing: 0.8,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
