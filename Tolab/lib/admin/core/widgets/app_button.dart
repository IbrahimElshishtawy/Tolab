import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../values/app_radius.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final isGhost = variant == AppButtonVariant.ghost;
    final child = isLoading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    return FilledButton.tonal(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: switch (variant) {
          AppButtonVariant.primary => AppColors.seed,
          AppButtonVariant.secondary => AppColors.seed.withValues(alpha: 0.12),
          AppButtonVariant.ghost => Colors.transparent,
        },
        foregroundColor: switch (variant) {
          AppButtonVariant.primary => Colors.white,
          _ => Theme.of(context).textTheme.bodyLarge?.color,
        },
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
        side: isGhost
            ? BorderSide(color: Theme.of(context).dividerColor)
            : null,
      ),
      child: child,
    );
  }
}

enum AppButtonVariant { primary, secondary, ghost }
