import 'package:flutter/material.dart';

class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);

  static const Curve curveStandard = Curves.easeInOut;
  static const Curve curveEmphasized = Curves.easeInOutCubic;
}
