import 'package:flutter/material.dart';

import '../colors/app_colors.dart';
import '../constants/app_constants.dart';
import '../typography/app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(
          brightness: brightness,
          seedColor: AppColors.primary,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.info,
          onSecondary: Colors.white,
          tertiary: AppColors.secondary,
          error: AppColors.danger,
          onError: Colors.white,
          surface: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          onSurface: isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
          outline: isDark ? AppColors.strokeDark : AppColors.strokeLight,
          shadow: isDark ? AppColors.shadowDark : AppColors.shadowLight,
          surfaceTint: Colors.transparent,
        );
    final textTheme = AppTypography.textTheme(brightness);
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;
    final elevatedSurface = isDark
        ? AppColors.surfaceElevatedDark
        : AppColors.surfaceElevatedLight;
    final mutedSurface = isDark
        ? AppColors.surfaceMutedDark
        : AppColors.surfaceMutedLight;
    final divider = isDark ? AppColors.strokeDark : AppColors.strokeLight;
    final shadow = isDark ? AppColors.shadowDark : AppColors.shadowLight;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      textTheme: textTheme,
      cardColor: surfaceColor,
      dividerColor: divider,
      canvasColor: elevatedSurface,
      shadowColor: shadow,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: AppColors.primary.withValues(alpha: 0.06),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        },
      ),
      dividerTheme: DividerThemeData(color: divider, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          side: BorderSide(color: divider),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        isDense: true,
        fillColor: mutedSurface,
        border: _inputBorder(isDark),
        enabledBorder: _inputBorder(isDark),
        focusedBorder: _inputBorder(isDark, focused: true),
        errorBorder: _inputBorder(isDark, error: true),
        focusedErrorBorder: _inputBorder(isDark, focused: true, error: true),
        labelStyle: textTheme.bodySmall,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        prefixIconColor: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
        suffixIconColor: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? AppColors.surfaceMutedDark
            : AppColors.surfaceMutedLight,
        selectedColor: AppColors.primarySoft,
        secondarySelectedColor: AppColors.primarySoft,
        disabledColor: mutedSurface,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
          side: BorderSide(color: divider),
        ),
        labelStyle: textTheme.labelMedium,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          elevation: const MaterialStatePropertyAll(0),
          minimumSize: const MaterialStatePropertyAll(
            Size(0, AppConstants.denseInputHeight),
          ),
          padding: const MaterialStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.smallRadius),
            ),
          ),
          textStyle: MaterialStatePropertyAll(textTheme.labelLarge),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return AppColors.primary.withValues(alpha: 0.42);
            }
            if (states.contains(MaterialState.pressed)) {
              return AppColors.primary.withValues(alpha: 0.92);
            }
            return AppColors.primary;
          }),
          foregroundColor: const MaterialStatePropertyAll(Colors.white),
          overlayColor: MaterialStatePropertyAll(
            Colors.white.withValues(alpha: 0.06),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          elevation: const MaterialStatePropertyAll(0),
          minimumSize: const MaterialStatePropertyAll(
            Size(0, AppConstants.denseInputHeight),
          ),
          padding: const MaterialStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.smallRadius),
            ),
          ),
          side: MaterialStatePropertyAll(BorderSide(color: divider)),
          textStyle: MaterialStatePropertyAll(textTheme.labelLarge),
          foregroundColor: MaterialStatePropertyAll(scheme.onSurface),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return AppColors.primary.withValues(alpha: 0.05);
            }
            return surfaceColor;
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStatePropertyAll(scheme.onSurface),
          textStyle: MaterialStatePropertyAll(textTheme.labelLarge),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.smallRadius),
            ),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const MaterialStatePropertyAll(Size(42, 42)),
          padding: const MaterialStatePropertyAll(EdgeInsets.zero),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return AppColors.primary.withValues(alpha: 0.10);
            }
            return elevatedSurface;
          }),
          foregroundColor: MaterialStatePropertyAll(scheme.onSurface),
          side: MaterialStatePropertyAll(BorderSide(color: divider)),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.smallRadius),
            ),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        ),
        iconColor: scheme.onSurface,
        textColor: scheme.onSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: MaterialStatePropertyAll(mutedSurface),
        headingTextStyle: textTheme.labelLarge?.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        dataTextStyle: textTheme.bodyMedium,
        dividerThickness: 0.6,
        horizontalMargin: 16,
        columnSpacing: 20,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: divider, width: 1.2),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.white;
          }
          return isDark ? AppColors.textSecondaryDark : Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return isDark ? AppColors.surfaceElevatedDark : AppColors.slateSoft;
        }),
        trackOutlineColor: MaterialStatePropertyAll(Colors.transparent),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.dialogRadius),
          side: BorderSide(color: divider),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          side: BorderSide(color: divider),
        ),
        textStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: elevatedSurface,
        modalBackgroundColor: elevatedSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.dialogRadius),
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: isDark
            ? AppColors.sidebarDark
            : AppColors.sidebarLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surfaceColor,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          side: BorderSide(color: divider),
        ),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(
    bool isDark, {
    bool focused = false,
    bool error = false,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.inputRadius),
      borderSide: BorderSide(
        width: focused ? 1.4 : 1,
        color: error
            ? AppColors.danger
            : focused
            ? AppColors.primary
            : isDark
            ? AppColors.strokeDark
            : AppColors.strokeLight,
      ),
    );
  }
}
