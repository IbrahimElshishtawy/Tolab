import 'package:flutter/material.dart';

class DashboardAppShadows {
  const DashboardAppShadows._();

  static List<BoxShadow> soft(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.10),
        blurRadius: 28,
        offset: const Offset(0, 14),
      ),
    ];
  }

  static List<BoxShadow> elevated(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.16),
        blurRadius: 38,
        offset: const Offset(0, 20),
      ),
    ];
  }
}
