import 'package:flutter/material.dart';

import '../theme/app_radii.dart';

enum AppButtonVariant { primary, secondary, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isExpanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final child = _buildButton();
    if (isExpanded) {
      return SizedBox(width: double.infinity, child: child);
    }
    return child;
  }

  Widget _buildButton() {
    final content = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label),
            ],
          );

    switch (variant) {
      case AppButtonVariant.primary:
        return FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
          ),
          child: content,
        );
      case AppButtonVariant.secondary:
        return FilledButton.tonal(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
          ),
          child: content,
        );
      case AppButtonVariant.ghost:
        return TextButton(onPressed: onPressed, child: content);
    }
  }
}
