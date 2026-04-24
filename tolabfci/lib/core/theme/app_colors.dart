import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2D66F6);
  static const primarySoft = Color(0xFFE8F0FF);
  static const teal = Color(0xFF23A4A1);
  static const indigo = Color(0xFF6B5CF6);
  static const success = Color(0xFF28A26A);
  static const warning = Color(0xFFF29A38);
  static const error = Color(0xFFE1605D);
  static const badge = Color(0xFFFF7B7B);
  static const support = Color(0xFF18A7C9);

  static const textPrimary = Color(0xFF162033);
  static const textSecondary = Color(0xFF647089);
  static const border = Color(0xFFE4EAF3);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF0F4FA);
  static const background = Color(0xFFF6F8FC);
}

@immutable
class AppColorsScheme extends ThemeExtension<AppColorsScheme> {
  const AppColorsScheme({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceElevated,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.primarySoft,
    required this.successSoft,
    required this.warningSoft,
    required this.errorSoft,
  });

  factory AppColorsScheme.light() {
    return const AppColorsScheme(
      background: Color(0xFFF6F8FC),
      surface: Color(0xFFFFFFFF),
      surfaceAlt: Color(0xFFF0F4FA),
      surfaceElevated: Color(0xFFFFFFFF),
      border: Color(0xFFE4EAF3),
      textPrimary: Color(0xFF162033),
      textSecondary: Color(0xFF647089),
      primarySoft: Color(0xFFE9F0FF),
      successSoft: Color(0xFFEAF7EF),
      warningSoft: Color(0xFFFFF4DE),
      errorSoft: Color(0xFFFFF0F0),
    );
  }

  factory AppColorsScheme.dark() {
    return const AppColorsScheme(
      background: Color(0xFF07111C),
      surface: Color(0xFF0F1B2B),
      surfaceAlt: Color(0xFF162536),
      surfaceElevated: Color(0xFF1A2A3F),
      border: Color(0xFF263954),
      textPrimary: Color(0xFFF5F7FF),
      textSecondary: Color(0xFFABB8CF),
      primarySoft: Color(0xFF173662),
      successSoft: Color(0xFF143120),
      warningSoft: Color(0xFF3B2A14),
      errorSoft: Color(0xFF3C1D22),
    );
  }

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color surfaceElevated;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color primarySoft;
  final Color successSoft;
  final Color warningSoft;
  final Color errorSoft;

  @override
  AppColorsScheme copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? surfaceElevated,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? primarySoft,
    Color? successSoft,
    Color? warningSoft,
    Color? errorSoft,
  }) {
    return AppColorsScheme(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      primarySoft: primarySoft ?? this.primarySoft,
      successSoft: successSoft ?? this.successSoft,
      warningSoft: warningSoft ?? this.warningSoft,
      errorSoft: errorSoft ?? this.errorSoft,
    );
  }

  @override
  ThemeExtension<AppColorsScheme> lerp(
    covariant ThemeExtension<AppColorsScheme>? other,
    double t,
  ) {
    if (other is! AppColorsScheme) {
      return this;
    }

    return AppColorsScheme(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      errorSoft: Color.lerp(errorSoft, other.errorSoft, t)!,
    );
  }
}

extension AppThemeColorsExtension on BuildContext {
  AppColorsScheme get appColors =>
      Theme.of(this).extension<AppColorsScheme>() ?? AppColorsScheme.light();
}
