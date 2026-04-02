import 'package:flutter/material.dart';

import '../design/app_colors.dart';
import '../design/app_spacing.dart';
import '../design/app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final surface = dark ? const Color(0xFF0F172A) : AppColors.white;
    final scaffold = dark ? const Color(0xFF020617) : AppColors.cloud50;
    final onSurface = dark ? AppColors.slate100 : AppColors.slate900;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.blue600,
      onPrimary: AppColors.white,
      secondary: AppColors.teal500,
      onSecondary: AppColors.white,
      error: AppColors.danger,
      onError: AppColors.white,
      surface: surface,
      onSurface: onSurface,
      tertiary: AppColors.aqua500,
      onTertiary: AppColors.white,
      surfaceContainerHighest: dark
          ? const Color(0xFF162033)
          : AppColors.slate100,
      outline: dark ? const Color(0xFF22304A) : AppColors.slate200,
      outlineVariant: dark ? const Color(0xFF1B2940) : AppColors.slate100,
      shadow: Colors.black26,
      scrim: Colors.black54,
      inverseSurface: dark ? AppColors.cloud50 : AppColors.slate900,
      onInverseSurface: dark ? AppColors.slate900 : AppColors.cloud50,
      inversePrimary: AppColors.blue500,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      textTheme: AppTypography.textTheme(brightness),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.textTheme(brightness).titleLarge,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF101A2D) : AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.blue600, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          backgroundColor: AppColors.blue600,
          foregroundColor: AppColors.white,
          textStyle: AppTypography.textTheme(brightness).labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        side: BorderSide(color: scheme.outlineVariant),
        selectedColor: AppColors.blue600.withValues(alpha: .12),
        backgroundColor: dark ? const Color(0xFF101A2D) : AppColors.white,
        labelStyle: AppTypography.textTheme(brightness).labelMedium,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),
      dividerTheme: DividerThemeData(
        thickness: 1,
        color: scheme.outlineVariant,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
