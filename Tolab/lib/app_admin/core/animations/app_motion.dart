import 'package:flutter/material.dart';

class AppMotion {
  const AppMotion._();

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 360);
  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve entrance = Curves.easeOutQuart;
}
