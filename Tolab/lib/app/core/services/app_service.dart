import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/storage_keys.dart';
import '../storage/local_storage_service.dart';

class AppService extends GetxService {
  AppService(this._localStorage);

  final LocalStorageService _localStorage;

  final Rx<Locale> locale = const Locale('en').obs;
  final RxBool isOnboardingSeen = false.obs;

  Future<AppService> init() async {
    final storedLanguage = _localStorage.readString(StorageKeys.locale);
    locale.value = Locale(
      storedLanguage?.isNotEmpty == true ? storedLanguage! : 'en',
    );
    isOnboardingSeen.value =
        _localStorage.readBool(StorageKeys.onboardingSeen) ?? false;
    return this;
  }

  Future<void> markOnboardingSeen() async {
    isOnboardingSeen.value = true;
    await _localStorage.writeBool(StorageKeys.onboardingSeen, true);
  }

  Future<void> setLocale(Locale nextLocale) async {
    locale.value = nextLocale;
    await _localStorage.writeString(
      StorageKeys.locale,
      nextLocale.languageCode,
    );
  }
}
