import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/services/theme_service.dart';
import '../../../data/models/admin_models.dart';
import '../../../data/repositories/admin/settings_repository.dart';

class SettingsController extends GetxController {
  SettingsController(
    this._repository,
    this._themeService,
    this._notificationService,
  );

  final SettingsRepository _repository;
  final ThemeService _themeService;
  final NotificationService _notificationService;
  final settings = Rxn<SettingsModel>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    settings.value = await _repository.getSettings();
  }

  Future<void> save(SettingsModel next) async {
    settings.value = await _repository.saveSettings(next);
    await _notificationService.savePreferences(
      push: next.pushNotifications,
      local: next.emailNotifications,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _themeService.updateThemeMode(mode);
}
