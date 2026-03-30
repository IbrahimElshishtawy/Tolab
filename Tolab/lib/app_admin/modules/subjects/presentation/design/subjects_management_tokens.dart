import 'package:flutter/material.dart';

import '../../../../core/animations/app_motion.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';

class SubjectsManagementPalette {
  const SubjectsManagementPalette._();

  static const Color accent = Color(0xFF0F6CBD);
  static const Color accentSoft = Color(0xFFDDEEFF);
  static const Color teal = Color(0xFF0F9D8A);
  static const Color tealSoft = Color(0xFFDDF9F1);
  static const Color coral = Color(0xFFFF7A59);
  static const Color coralSoft = Color(0xFFFFE8E1);
  static const Color violet = Color(0xFF6457F6);
  static const Color violetSoft = Color(0xFFE8E6FF);
  static const Color gold = Color(0xFFF5A524);
  static const Color goldSoft = Color(0xFFFFF2D8);
  static const Color neutral = Color(0xFF63748A);

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

  static LinearGradient heroGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: [
        accent.withValues(alpha: isDark ? 0.28 : 0.16),
        violet.withValues(alpha: isDark ? 0.24 : 0.12),
        teal.withValues(alpha: isDark ? 0.18 : 0.10),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

class SubjectsManagementSpacing {
  const SubjectsManagementSpacing._();

  static const double pageGap = AppSpacing.xl;
  static const double sectionGap = AppSpacing.lg;
  static const double analyticsMinWidth = 270;
  static const double detailsPanelWidth = 430;
  static const double tableMinWidth = 980;
}

class SubjectsManagementDecorations {
  const SubjectsManagementDecorations._();

  static BoxDecoration tintedPanel(
    BuildContext context, {
    required Color tint,
    double opacity = 0.10,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: tint.withValues(alpha: isDark ? opacity + 0.05 : opacity),
      borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      border: Border.all(
        color: tint.withValues(alpha: isDark ? opacity + 0.14 : opacity + 0.08),
      ),
    );
  }

  static List<BoxShadow> softShadow(
    BuildContext context, {
    bool hover = false,
  }) {
    final shadow = Theme.of(context).brightness == Brightness.dark
        ? AppColors.shadowDark
        : AppColors.shadowLight;
    return [
      BoxShadow(
        color: shadow.withValues(alpha: hover ? 0.22 : 0.13),
        blurRadius: hover ? 30 : 24,
        offset: Offset(0, hover ? 18 : 14),
      ),
    ];
  }
}

class SubjectsManagementButtons {
  const SubjectsManagementButtons._();

  static ButtonStyle subtle(BuildContext context, {Color? tint}) {
    final color = tint ?? SubjectsManagementPalette.accent;
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

class SubjectBadgeTone {
  const SubjectBadgeTone({required this.foreground, required this.background});

  final Color foreground;
  final Color background;
}

class SubjectsManagementBadges {
  const SubjectsManagementBadges._();

  static SubjectBadgeTone toneFor(String label) {
    final normalized = label.toLowerCase();
    if (normalized.contains('active') ||
        normalized.contains('healthy') ||
        normalized.contains('enabled') ||
        normalized.contains('students only') ||
        normalized.contains('live')) {
      return const SubjectBadgeTone(
        foreground: SubjectsManagementPalette.teal,
        background: SubjectsManagementPalette.tealSoft,
      );
    }
    if (normalized.contains('draft') ||
        normalized.contains('watch') ||
        normalized.contains('late') ||
        normalized.contains('monitor') ||
        normalized.contains('pending')) {
      return const SubjectBadgeTone(
        foreground: SubjectsManagementPalette.gold,
        background: SubjectsManagementPalette.goldSoft,
      );
    }
    if (normalized.contains('private') ||
        normalized.contains('staff') ||
        normalized.contains('doctor')) {
      return const SubjectBadgeTone(
        foreground: SubjectsManagementPalette.violet,
        background: SubjectsManagementPalette.violetSoft,
      );
    }
    if (normalized.contains('inactive') ||
        normalized.contains('restricted') ||
        normalized.contains('closed') ||
        normalized.contains('flagged')) {
      return const SubjectBadgeTone(
        foreground: SubjectsManagementPalette.coral,
        background: SubjectsManagementPalette.coralSoft,
      );
    }
    return const SubjectBadgeTone(
      foreground: SubjectsManagementPalette.accent,
      background: SubjectsManagementPalette.accentSoft,
    );
  }
}
