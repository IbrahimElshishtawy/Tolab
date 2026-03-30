import 'package:flutter/material.dart';

import '../../core/colors/app_colors.dart';
import '../../core/constants/app_constants.dart';

class PremiumButton extends StatelessWidget {
  const PremiumButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isSecondary = false,
    this.isDestructive = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.strokeDark : AppColors.strokeLight;
    final backgroundColor = isDestructive
        ? AppColors.danger
        : isSecondary
        ? Theme.of(context).cardColor
        : AppColors.primary;
    final foregroundColor = isSecondary
        ? Theme.of(context).colorScheme.onSurface
        : Colors.white;

    final style = ButtonStyle(
      elevation: const WidgetStatePropertyAll(0),
      minimumSize: const WidgetStatePropertyAll(
        Size(0, AppConstants.denseInputHeight),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
      side: isSecondary
          ? WidgetStatePropertyAll(BorderSide(color: borderColor))
          : null,
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return backgroundColor.withValues(alpha: 0.4);
        }
        if (states.contains(WidgetState.pressed)) {
          return backgroundColor.withValues(alpha: 0.9);
        }
        return backgroundColor;
      }),
      foregroundColor: WidgetStatePropertyAll(foregroundColor),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        ),
      ),
    );

    if (icon == null) {
      return FilledButton(
        onPressed: onPressed,
        style: style,
        child: Text(label),
      );
    }

    return FilledButton.icon(
      onPressed: onPressed,
      style: style,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
