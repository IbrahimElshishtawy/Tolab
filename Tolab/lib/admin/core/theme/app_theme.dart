import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../typography/app_typography.dart';
import '../values/app_radius.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _theme(Brightness.light);
  static ThemeData dark() => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color scaffold = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final Color surface = isDark ? AppColors.darkSurface : AppColors.lightCard;
    final Color border = isDark ? AppColors.darkStroke : AppColors.stroke;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        brightness: brightness,
        seedColor: AppColors.seed,
        surface: surface,
      ),
      scaffoldBackgroundColor: scaffold,
      textTheme: AppTypography.textTheme(brightness),
      dividerColor: border,
    );

    return base.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AppColors.darkCard.withValues(alpha: 0.55)
            : AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.card,
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.card,
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.card,
          borderSide: BorderSide(color: AppColors.seed, width: 1.4),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: border.withValues(alpha: 0.65)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.darkCard : AppColors.textPrimary,
      ),
    );
  }
}
