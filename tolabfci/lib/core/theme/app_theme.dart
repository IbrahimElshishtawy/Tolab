import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData light() {
    return _buildTheme(
      brightness: Brightness.light,
      palette: AppColorsScheme.light(),
    );
  }

  static ThemeData dark() {
    return _buildTheme(
      brightness: Brightness.dark,
      palette: AppColorsScheme.dark(),
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required AppColorsScheme palette,
  }) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.teal,
          tertiary: AppColors.indigo,
          error: AppColors.error,
          surface: palette.surface,
          onSurface: palette.textPrimary,
          outline: palette.border,
          outlineVariant: palette.border,
          surfaceContainerHighest: palette.surfaceAlt,
        );

    final textTheme = TextTheme(
      displaySmall: AppTextStyles.titleLarge.copyWith(
        color: palette.textPrimary,
      ),
      headlineSmall: AppTextStyles.titleMedium.copyWith(
        color: palette.textPrimary,
      ),
      titleLarge: AppTextStyles.heading.copyWith(color: palette.textPrimary),
      bodyLarge: AppTextStyles.body.copyWith(color: palette.textPrimary),
      bodyMedium: AppTextStyles.body.copyWith(color: palette.textPrimary),
      bodySmall: AppTextStyles.bodyMuted.copyWith(color: palette.textSecondary),
      labelLarge: AppTextStyles.label.copyWith(color: palette.textSecondary),
    );

    final shadowAlpha = brightness == Brightness.dark ? 0.30 : 0.08;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: [palette],
      fontFamilyFallback: const [
        'SF Pro Display',
        'SF Pro Text',
        'Noto Sans Arabic',
        'Segoe UI',
        'Tahoma',
        'Arial',
      ],
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      cardColor: palette.surface,
      dividerColor: palette.border,
      shadowColor: Colors.black.withValues(alpha: shadowAlpha),
      visualDensity: VisualDensity.comfortable,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: palette.textPrimary,
        titleTextStyle: textTheme.titleLarge,
      ),
      cupertinoOverrideTheme: NoDefaultCupertinoThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: palette.background,
        barBackgroundColor: palette.surface,
        textTheme: CupertinoTextThemeData(
          textStyle: textTheme.bodyMedium,
          navTitleTextStyle: textTheme.titleLarge,
          navLargeTitleTextStyle: textTheme.displaySmall,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceElevated,
        hintStyle: textTheme.bodySmall,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface.withValues(alpha: 0.95),
        indicatorColor: palette.primarySoft,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(
          alpha: brightness == Brightness.dark ? 0.22 : 0.06,
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelLarge?.copyWith(
            color: states.contains(WidgetState.selected)
                ? palette.textPrimary
                : palette.textSecondary,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: palette.surface,
        indicatorColor: palette.primarySoft,
        useIndicator: true,
        selectedIconTheme: const IconThemeData(color: AppColors.primary),
        unselectedIconTheme: IconThemeData(color: palette.textSecondary),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.surfaceElevated,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          side: BorderSide(color: palette.border),
        ),
        backgroundColor: palette.surfaceAlt,
        selectedColor: palette.primarySoft,
        labelStyle: textTheme.labelLarge,
        side: BorderSide(color: palette.border),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: palette.textPrimary,
        unselectedLabelColor: palette.textSecondary,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: palette.primarySoft,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        iconColor: palette.textSecondary,
        textColor: palette.textPrimary,
      ),
    );
  }
}
