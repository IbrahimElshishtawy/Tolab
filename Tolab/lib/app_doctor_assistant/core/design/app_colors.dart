import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color slate900 = Color(0xFF111827);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color cloud50 = Color(0xFFF8FAFC);
  static const Color white = Color(0xFFFFFFFF);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color aqua500 = Color(0xFF0EA5E9);
  static const Color teal500 = Color(0xFF14B8A6);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color success = emerald500;
  static const Color warning = amber500;
  static const Color danger = rose500;
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1D4ED8), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
