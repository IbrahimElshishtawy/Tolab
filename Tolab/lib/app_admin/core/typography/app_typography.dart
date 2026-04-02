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
            fontSize: 32,
            letterSpacing: -1.4,
          ),
          displayMedium: base.displayMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: primary,
            fontSize: 26,
            letterSpacing: -1.1,
          ),
          headlineLarge: base.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: primary,
            fontSize: 22,
            letterSpacing: -0.9,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: primary,
            fontSize: 16,
            letterSpacing: -0.4,
          ),
          headlineSmall: base.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: primary,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
          titleLarge: base.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: primary,
            fontSize: 16,
            letterSpacing: -0.2,
          ),
          titleMedium: base.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: primary,
            fontSize: 13,
          ),
          titleSmall: base.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: primary,
            fontSize: 12,
            letterSpacing: 0.1,
          ),
          bodyLarge: base.bodyLarge?.copyWith(
            color: primary,
            height: 1.4,
            fontSize: 12,
          ),
          bodyMedium: base.bodyMedium?.copyWith(
            color: primary,
            height: 1.38,
            fontSize: 11,
          ),
          bodySmall: base.bodySmall?.copyWith(
            color: secondary,
            height: 1.32,
            fontSize: 10,
          ),
          labelLarge: base.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: primary,
            fontSize: 12,
            letterSpacing: 0.1,
          ),
          labelMedium: base.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: secondary,
            fontSize: 10,
            letterSpacing: 0.15,
          ),
          labelSmall: base.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: secondary,
            fontSize: 10,
            letterSpacing: 0.2,
          ),
        );
  }
}
