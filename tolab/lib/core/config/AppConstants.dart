// lib/core/config/constants.dart

// ignore_for_file: file_names

import 'package:flutter/material.dart';

/// Constants used across the app
class AppConstants {
  // Colors
  static const primaryColor = Color(0xFF0D14D9);
  static const secondaryColor = Color(0xFF98ACC9);
  static const backgroundColor = Color(0xFFF5F7FA);
  static const dangerColor = Colors.redAccent;
  static const textColor = Colors.black87;

  // Padding & Margins
  static const defaultPadding = 16.0;
  static const borderRadius = 12.0;
  static const buttonSpacing = 6.0;

  // Asset paths
  static const logoPath = 'assets/image_App/Tolab.png';

  // App name
  static const appName = 'ToLab';

  // Font sizes
  static const double headingFontSize = 18;
  static const double bodyFontSize = 14;
  static const double largeFontSize = 30;

  // Durations
  static const Duration animationDuration = Duration(milliseconds: 300);

  // User data (for demo purposes)
  static const userName = 'إبراهيم الششتاوي';
  static const userAvatarRadius = 35.0;

  // Icon sizes
  static const double iconSize = 20.0;

  // Logo parts
  static const String logoPrefix = 'ToL';
  static const String logoSuffix = 'Ab';
}
