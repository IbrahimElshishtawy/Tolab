import 'package:flutter/material.dart';

import 'app_colors.dart';

enum DashboardGraphicStyle { executiveDarkPremium, softLightIosAcademic }

class DashboardThemeTokens {
  const DashboardThemeTokens({
    required this.style,
    required this.pageBackground,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.primary,
    required this.secondary,
    required this.success,
    required this.warning,
    required this.danger,
    required this.textPrimary,
    required this.textSecondary,
    required this.glow,
  });

  final DashboardGraphicStyle style;
  final Color pageBackground;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color primary;
  final Color secondary;
  final Color success;
  final Color warning;
  final Color danger;
  final Color textPrimary;
  final Color textSecondary;
  final Color glow;

  bool get isDark => style == DashboardGraphicStyle.executiveDarkPremium;

  String get styleName =>
      isDark ? 'Executive Dark Premium' : 'Soft Light iOS Academic';

  static DashboardThemeTokens of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const DashboardThemeTokens(
            style: DashboardGraphicStyle.executiveDarkPremium,
            pageBackground: DashboardExecutiveColors.page,
            surface: DashboardExecutiveColors.surface,
            surfaceAlt: DashboardExecutiveColors.surfaceAlt,
            border: DashboardExecutiveColors.border,
            primary: DashboardExecutiveColors.primary,
            secondary: DashboardExecutiveColors.secondary,
            success: DashboardExecutiveColors.success,
            warning: DashboardExecutiveColors.warning,
            danger: DashboardExecutiveColors.danger,
            textPrimary: DashboardExecutiveColors.textPrimary,
            textSecondary: DashboardExecutiveColors.textSecondary,
            glow: DashboardExecutiveColors.glow,
          )
        : const DashboardThemeTokens(
            style: DashboardGraphicStyle.softLightIosAcademic,
            pageBackground: DashboardSoftColors.page,
            surface: DashboardSoftColors.surface,
            surfaceAlt: DashboardSoftColors.surfaceAlt,
            border: DashboardSoftColors.border,
            primary: DashboardSoftColors.primary,
            secondary: DashboardSoftColors.secondary,
            success: DashboardSoftColors.success,
            warning: DashboardSoftColors.warning,
            danger: DashboardSoftColors.danger,
            textPrimary: DashboardSoftColors.textPrimary,
            textSecondary: DashboardSoftColors.textSecondary,
            glow: DashboardSoftColors.glow,
          );
  }
}
