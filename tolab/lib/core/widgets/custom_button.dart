// lib/core/widgets/custom_button.dart

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final bool iconAtEnd;
  final double borderRadius;
  final double fontSize;
  final bool isBold;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 48,
    this.backgroundColor = const Color(0xFF0D14D9),
    this.textColor = Colors.white,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.iconAtEnd = false,
    this.borderRadius = 12,
    this.fontSize = 16,
    this.isBold = true,
  });

  @override
  Widget build(BuildContext context) {
    final isButtonEnabled = !isDisabled && !isLoading;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isButtonEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isButtonEnabled
              ? backgroundColor
              : Colors.grey.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null && !iconAtEnd) ...[
                    Icon(icon, size: 20, color: textColor),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: fontSize,
                      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (icon != null && iconAtEnd) ...[
                    const SizedBox(width: 8),
                    Icon(icon, size: 20, color: textColor),
                  ],
                ],
              ),
      ),
    );
  }
}
