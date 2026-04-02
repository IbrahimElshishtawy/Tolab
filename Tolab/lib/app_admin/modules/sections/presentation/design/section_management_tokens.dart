import 'package:flutter/material.dart';

import '../../../../core/colors/app_colors.dart';

class SectionManagementPalette {
  const SectionManagementPalette._();

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color surface(BuildContext context) => Theme.of(context).cardColor;

  static Color elevated(BuildContext context) => isDark(context)
      ? AppColors.surfaceElevatedDark
      : AppColors.surfaceElevatedLight;

  static Color muted(BuildContext context) => isDark(context)
      ? AppColors.surfaceMutedDark
      : AppColors.surfaceMutedLight;

  static Color subtleText(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall?.color ??
      (isDark(context)
          ? AppColors.textSecondaryDark
          : AppColors.textSecondaryLight);

  static Color softShadow(BuildContext context) =>
      isDark(context) ? AppColors.shadowDark : AppColors.shadowLight;

  static Color progressTrack(BuildContext context) => isDark(context)
      ? AppColors.strokeDark.withValues(alpha: 0.72)
      : AppColors.slateSoft.withValues(alpha: 0.35);

  static Color frostedSurface(
    BuildContext context, {
    double lightAlpha = 0.78,
  }) => isDark(context)
      ? elevated(context).withValues(alpha: 0.94)
      : Colors.white.withValues(alpha: lightAlpha);

  static LinearGradient glassGradient(BuildContext context) {
    final dark = isDark(context);
    return LinearGradient(
      colors: [
        Colors.white.withValues(alpha: dark ? 0.08 : 0.72),
        Colors.white.withValues(alpha: dark ? 0.04 : 0.42),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static Color glassBorder(BuildContext context) =>
      Colors.white.withValues(alpha: isDark(context) ? 0.10 : 0.44);

  static LinearGradient pageGradient(BuildContext context) {
    if (isDark(context)) {
      return const LinearGradient(
        colors: [
          AppColors.backgroundDark,
          AppColors.surfaceMutedDark,
          AppColors.surfaceDark,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return const LinearGradient(
      colors: [Color(0xFFF6F8FC), Color(0xFFEFF4FB), Color(0xFFF8FAFD)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static Color orbPrimary(BuildContext context) =>
      AppColors.primary.withValues(alpha: isDark(context) ? 0.14 : 0.20);

  static Color orbSuccess(BuildContext context) =>
      AppColors.secondary.withValues(alpha: isDark(context) ? 0.12 : 0.13);

  static Color orbWarning(BuildContext context) =>
      AppColors.warning.withValues(alpha: isDark(context) ? 0.12 : 0.13);

  static Color mobileFrame(BuildContext context) =>
      isDark(context) ? const Color(0xFF08111F) : AppColors.surfaceMutedDark;

  static Color mobileCanvas(BuildContext context) =>
      isDark(context) ? surface(context) : const Color(0xFFF7F9FD);

  static Color mobileHandle(BuildContext context) =>
      Colors.black.withValues(alpha: isDark(context) ? 0.26 : 0.10);

  static Color selectedTextOnAccent(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;
}
