import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.dense = false,
  });

  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final defaultBackground = Theme.of(context).brightness == Brightness.dark
        ? palette.surfaceAlt.withValues(alpha: 0.92)
        : palette.primarySoft;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBackground,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: palette.border.withValues(alpha: 0.7)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: foregroundColor ?? palette.textPrimary,
        ),
      ),
    );
  }
}
