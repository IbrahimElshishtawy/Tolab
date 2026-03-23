import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/storage_keys.dart';
import '../storage/local_storage_service.dart';

class ThemeService extends GetxService {
  ThemeService(this._localStorage);

  final LocalStorageService _localStorage;

  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  Future<ThemeService> init() async {
    final storedMode = _localStorage.readString(StorageKeys.themeMode);
    themeMode.value = ThemeMode.values.firstWhere(
      (item) => item.name == storedMode,
      orElse: () => ThemeMode.system,
    );
    return this;
  }

  Future<void> setThemeMode(ThemeMode nextMode) async {
    themeMode.value = nextMode;
    await _localStorage.writeString(StorageKeys.themeMode, nextMode.name);
  }

  bool isDark(BuildContext context) => themeMode.value == ThemeMode.system
      ? Theme.of(context).brightness == Brightness.dark
      : themeMode.value == ThemeMode.dark;
}
