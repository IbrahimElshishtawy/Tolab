import 'package:flutter/material.dart';

import '../../../../core/animations/app_motion.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';

class StaffManagementPalette {
  const StaffManagementPalette._();

  static const Color doctor = Color(0xFF2563EB);
  static const Color assistant = Color(0xFF0EA5E9);
  static const Color internal = Color(0xFF14B8A6);
  static const Color delegated = Color(0xFFF59E0B);
  static const Color attendance = Color(0xFF10B981);
  static const Color engagement = Color(0xFF7C3AED);
  static const Color risk = Color(0xFFEF4444);
  static const Color neutral = Color(0xFF64748B);

  static Color surface(BuildContext context) => Theme.of(context).cardColor;

  static Color muted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.surfaceMutedDark
          : AppColors.surfaceMutedLight;

  static Color elevated(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? AppColors.surfaceElevatedDark
          : AppColors.surfaceElevatedLight;

  static Color border(BuildContext context) => Theme.of(context).dividerColor;

  static Color subtleText(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall?.color ?? AppColors.slate;
}

class StaffManagementSpacing {
  const StaffManagementSpacing._();

  static const double pageGap = AppSpacing.xl;
  static const double sectionGap = AppSpacing.lg;
  static const double detailsWidth = 430;
  static const double analyticsMinWidth = 295;
  static const double compactAnalyticsMinWidth = 260;
}

class StaffManagementDecorations {
  const StaffManagementDecorations._();

  static List<BoxShadow> softShadow(BuildContext context, {bool hover = false}) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? AppColors.shadowDark
        : AppColors.shadowLight;
    return [
      BoxShadow(
        color: base.withValues(alpha: hover ? 0.24 : 0.12),
        blurRadius: hover ? 34 : 24,
        offset: Offset(0, hover ? 18 : 12),
      ),
    ];
  }

  static BoxDecoration tintedPanel(
    BuildContext context, {
    required Color tint,
    double opacity = 0.10,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: tint.withValues(alpha: isDark ? opacity + 0.04 : opacity),
      borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      border: Border.all(
        color: tint.withValues(alpha: isDark ? opacity + 0.18 : opacity + 0.10),
      ),
    );
  }

  static BoxDecoration outline(BuildContext context) {
    return BoxDecoration(
      color: StaffManagementPalette.muted(context),
      borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      border: Border.all(color: StaffManagementPalette.border(context)),
    );
  }

  static LinearGradient heroGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: [
        StaffManagementPalette.doctor.withValues(alpha: isDark ? 0.28 : 0.16),
        StaffManagementPalette.engagement.withValues(alpha: isDark ? 0.24 : 0.10),
        StaffManagementPalette.assistant.withValues(alpha: isDark ? 0.18 : 0.07),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

class StaffManagementButtons {
  const StaffManagementButtons._();

  static ButtonStyle subtle(BuildContext context, {Color? tint}) {
    final color = tint ?? StaffManagementPalette.doctor;
    return ButtonStyle(
      animationDuration: AppMotion.fast,
      minimumSize: const WidgetStatePropertyAll(Size(0, 42)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      foregroundColor: WidgetStatePropertyAll(color),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        final pressed = states.contains(WidgetState.pressed);
        return color.withValues(alpha: pressed ? 0.18 : 0.10);
      }),
      side: WidgetStatePropertyAll(
        BorderSide(color: color.withValues(alpha: 0.14)),
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

class StaffBadgeTone {
  const StaffBadgeTone({required this.foreground, required this.background});

  final Color foreground;
  final Color background;
}

class StaffManagementBadges {
  const StaffManagementBadges._();

  static StaffBadgeTone toneForLabel(BuildContext context, String label) {
    final normalized = label.toLowerCase();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color foreground = StaffManagementPalette.neutral;
    if (normalized.contains('active') ||
        normalized.contains('synced') ||
        normalized.contains('healthy') ||
        normalized.contains('strong') ||
        normalized.contains('excellent') ||
        normalized.contains('stable') ||
        normalized.contains('enabled')) {
      foreground = StaffManagementPalette.attendance;
    } else if (normalized.contains('doctor')) {
      foreground = StaffManagementPalette.doctor;
    } else if (normalized.contains('assistant')) {
      foreground = StaffManagementPalette.assistant;
    } else if (normalized.contains('internal')) {
      foreground = StaffManagementPalette.internal;
    } else if (normalized.contains('delegated') ||
        normalized.contains('external') ||
        normalized.contains('pending') ||
        normalized.contains('watch') ||
        normalized.contains('moderate')) {
      foreground = StaffManagementPalette.delegated;
    } else if (normalized.contains('inactive') ||
        normalized.contains('disabled') ||
        normalized.contains('critical') ||
        normalized.contains('suspended') ||
        normalized.contains('risk')) {
      foreground = StaffManagementPalette.risk;
    } else if (normalized.contains('monitor') ||
        normalized.contains('review') ||
        normalized.contains('activity')) {
      foreground = StaffManagementPalette.engagement;
    }

    return StaffBadgeTone(
      foreground: foreground,
      background: foreground.withValues(alpha: isDark ? 0.18 : 0.12),
    );
  }
}
