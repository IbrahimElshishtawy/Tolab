import 'package:flutter/material.dart';

class DashboardAppTypography {
  const DashboardAppTypography._();

  static TextStyle eyebrow(BuildContext context, Color color) {
    return Theme.of(context).textTheme.labelMedium!.copyWith(
      color: color,
      fontWeight: FontWeight.w700,
      letterSpacing: 0,
    );
  }

  static TextStyle metric(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
    );
  }
}
