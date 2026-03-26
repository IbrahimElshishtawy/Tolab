import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color seed = Color(0xFF4D8DFF);
  static const Color lightBackground = Color(0xFFF5F7FB);
  static const Color lightSurface = Color(0xFFFDFEFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF0F1728);
  static const Color darkSurface = Color(0xFF141D31);
  static const Color darkCard = Color(0xFF1B2740);
  static const Color textPrimary = Color(0xFF142033);
  static const Color textSecondary = Color(0xFF637188);
  static const Color darkTextPrimary = Color(0xFFF5F8FF);
  static const Color darkTextSecondary = Color(0xFFA4B0C3);
  static const Color stroke = Color(0xFFE5EAF3);
  static const Color darkStroke = Color(0xFF2A3854);
  static const Color success = Color(0xFF20B26C);
  static const Color warning = Color(0xFFFFAE42);
  static const Color danger = Color(0xFFFF5F5F);
  static const Color info = Color(0xFF4D8DFF);

  static const LinearGradient pageGlow = LinearGradient(
    colors: [Color(0xFFFDFEFF), Color(0xFFF3F7FF), Color(0xFFF7FAFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGlow = LinearGradient(
    colors: [Color(0xFF0F1728), Color(0xFF101C33), Color(0xFF18243E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
