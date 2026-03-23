import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/app_service.dart';
import '../../../core/services/theme_service.dart';
import '../../auth/controllers/auth_controller.dart';

class SettingsController extends GetxController {
  SettingsController(
    this._themeService,
    this._appService,
    this._authController,
  );

  final ThemeService _themeService;
  final AppService _appService;
  final AuthController _authController;

  Rx<ThemeMode> get mode => _themeService.themeMode;
  Rx<Locale> get locale => _appService.locale;

  Future<void> setThemeMode(ThemeMode value) =>
      _themeService.setThemeMode(value);
  Future<void> setLocale(Locale value) => _appService.setLocale(value);
  Future<void> logout() => _authController.logout();
}
