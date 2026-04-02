import 'package:flutter/material.dart';

import '../../../../core/animations/app_motion.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';

class StudentsAdminPalette {
  const StudentsAdminPalette._();

  static const Color grade = Color(0xFF3B82F6);
  static const Color attendance = Color(0xFF06B6D4);
  static const Color activity = Color(0xFF14B8A6);
  static const Color interaction = Color(0xFFF59E0B);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF97316);
  static const Color danger = Color(0xFFEF4444);
  static const Color neutral = Color(0xFF64748B);
  static const Color mintSoft = Color(0xFFE7FFF6);
  static const Color blueSoft = Color(0xFFE9F1FF);
  static const Color amberSoft = Color(0xFFFFF4DE);
  static const Color roseSoft = Color(0xFFFFE9E8);

  static Color surface(BuildContext context) => Theme.of(context).cardColor;

  static Color elevated(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColors.surfaceElevatedDark
      : AppColors.surfaceElevatedLight;

  static Color muted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? AppColors.surfaceMutedDark
      : AppColors.surfaceMutedLight;

  static Color border(BuildContext context) => Theme.of(context).dividerColor;

  static Color subtleText(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall?.color ?? AppColors.slate;
}

class StudentsAdminSpacing {
  const StudentsAdminSpacing._();

  static const double pageGap = AppSpacing.xl;
  static const double sectionGap = AppSpacing.lg;
  static const double panelPadding = AppSpacing.lg;
  static const double cardMinHeight = 218;
  static const double detailPanelWidth = 344;
  static const double analyticsMinWidth = 232;
}

class StudentsAdminDecorations {
  const StudentsAdminDecorations._();

  static List<BoxShadow> softShadow(
    BuildContext context, {
    bool hover = false,
  }) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? AppColors.shadowDark
        : AppColors.shadowLight;
    return [
      BoxShadow(
        color: base.withValues(alpha: hover ? 0.2 : 0.12),
        blurRadius: hover ? 30 : 22,
        offset: Offset(0, hover ? 18 : 12),
      ),
    ];
  }

  static BoxDecoration tintedPanel(
    BuildContext context, {
    required Color tint,
    double opacity = 0.08,
  }) {
    return BoxDecoration(
      color: tint.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      border: Border.all(color: tint.withValues(alpha: opacity + 0.08)),
    );
  }
}

class StudentsAdminButtons {
  const StudentsAdminButtons._();

  static ButtonStyle subtle(BuildContext context, {Color? tint}) {
    final color = tint ?? AppColors.primary;
    return ButtonStyle(
      animationDuration: AppMotion.fast,
      minimumSize: const WidgetStatePropertyAll(Size(0, 42)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        final pressed = states.contains(WidgetState.pressed);
        return color.withValues(alpha: pressed ? 0.16 : 0.09);
      }),
      foregroundColor: WidgetStatePropertyAll(color),
      side: WidgetStatePropertyAll(
        BorderSide(color: color.withValues(alpha: 0.12)),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        ),
      ),
      textStyle: WidgetStatePropertyAll(Theme.of(context).textTheme.labelLarge),
    );
  }
}

class StudentsAdminBadgeTone {
  const StudentsAdminBadgeTone({
    required this.foreground,
    required this.background,
  });

  final Color foreground;
  final Color background;
}

class StudentsAdminBadges {
  const StudentsAdminBadges._();

  static StudentsAdminBadgeTone toneForStatus(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('active') || normalized.contains('excellent')) {
      return const StudentsAdminBadgeTone(
        foreground: StudentsAdminPalette.success,
        background: StudentsAdminPalette.mintSoft,
      );
    }
    if (normalized.contains('watch') || normalized.contains('probation')) {
      return const StudentsAdminBadgeTone(
        foreground: StudentsAdminPalette.warning,
        background: StudentsAdminPalette.amberSoft,
      );
    }
    if (normalized.contains('hold') || normalized.contains('inactive')) {
      return const StudentsAdminBadgeTone(
        foreground: StudentsAdminPalette.danger,
        background: StudentsAdminPalette.roseSoft,
      );
    }
    return const StudentsAdminBadgeTone(
      foreground: StudentsAdminPalette.grade,
      background: StudentsAdminPalette.blueSoft,
    );
  }
}
