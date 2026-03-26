import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../colors/app_colors.dart';

class AppTypography {
  const AppTypography._();

  static TextTheme textTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = GoogleFonts.manropeTextTheme();
    final primary = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondary = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return base
        .apply(bodyColor: primary, displayColor: primary)
        .copyWith(
          displayLarge: base.displayLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: primary,
            fontSize: 28,
            letterSpacing: -2.1,
          ),
          displayMedium: base.displayMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: primary,
            fontSize: 28,
            letterSpacing: -1.7,
          ),
          headlineLarge: base.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: primary,
            fontSize: 18,
            letterSpacing: -1.4,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: primary,
            fontSize: 10,
            letterSpacing: -0.9,
          ),
          headlineSmall: base.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: primary,
            fontSize: 14,
            letterSpacing: -0.6,
          ),
          titleLarge: base.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: primary,
            fontSize: 10,
            letterSpacing: -0.3,
          ),
          titleMedium: base.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: primary,
            fontSize: 17,
          ),
          titleSmall: base.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: primary,
            fontSize: 14,
            letterSpacing: 0.1,
          ),
          bodyLarge: base.bodyLarge?.copyWith(
            color: primary,
            height: 1.48,
            fontSize: 16,
          ),
          bodyMedium: base.bodyMedium?.copyWith(
            color: primary,
            height: 1.45,
            fontSize: 14,
          ),
          bodySmall: base.bodySmall?.copyWith(
            color: secondary,
            height: 1.38,
            fontSize: 12,
          ),
          labelLarge: base.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: primary,
            fontSize: 14,
            letterSpacing: 0.1,
          ),
          labelMedium: base.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: secondary,
            fontSize: 12,
            letterSpacing: 0.15,
          ),
          labelSmall: base.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: secondary,
            fontSize: 11,
            letterSpacing: 0.35,
          ),
        );
  }
}
