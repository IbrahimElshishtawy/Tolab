import 'package:flutter/material.dart';

class AppShadows {
  const AppShadows._();

  static List<BoxShadow> card(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: (isDark ? Colors.black : const Color(0xFF7F8DBD)).withValues(
          alpha: isDark ? 0.2 : 0.08,
        ),
        blurRadius: isDark ? 24 : 32,
        offset: const Offset(0, 14),
      ),
    ];
  }
}
