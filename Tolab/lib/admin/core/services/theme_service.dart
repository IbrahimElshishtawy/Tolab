import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/storage_keys.dart';
import '../storage/local_storage_service.dart';

class ThemeService extends GetxService {
  ThemeService(this._storage);

  final LocalStorageService _storage;
  final themeMode = ThemeMode.system.obs;

  Future<ThemeService> init() async {
    final stored = _storage.read(StorageKeys.themeMode);
    themeMode.value = switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    return this;
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _storage.write(StorageKeys.themeMode, switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
    Get.changeThemeMode(mode);
  }
}
