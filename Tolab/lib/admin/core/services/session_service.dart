import 'dart:convert';

import 'package:get/get.dart';

import '../../data/models/admin_models.dart';
import '../constants/storage_keys.dart';
import '../storage/local_storage_service.dart';
import '../storage/secure_storage_service.dart';

class SessionService extends GetxService {
  SessionService({
    required SecureStorageService secureStorage,
    required LocalStorageService localStorage,
  }) : _secureStorage = secureStorage,
       _localStorage = localStorage;

  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;
  final accessToken = RxnString();
  final refreshToken = RxnString();
  final profile = Rxn<ProfileModel>();

  bool get isAuthenticated => accessToken.value?.isNotEmpty == true;

  Future<SessionService> init() async {
    accessToken.value = await _secureStorage.read(StorageKeys.accessToken);
    refreshToken.value = await _secureStorage.read(StorageKeys.refreshToken);
    final cached = _localStorage.read(StorageKeys.profileCache);
    if (cached != null) {
      profile.value = ProfileModel.fromJson(
        jsonDecode(cached) as Map<String, dynamic>,
      );
    }
    return this;
  }

  Future<void> saveSession({
    required String access,
    required String refresh,
    required ProfileModel user,
  }) async {
    accessToken.value = access;
    refreshToken.value = refresh;
    profile.value = user;
    await _secureStorage.write(StorageKeys.accessToken, access);
    await _secureStorage.write(StorageKeys.refreshToken, refresh);
    await _localStorage.write(
      StorageKeys.profileCache,
      jsonEncode(user.toJson()),
    );
  }

  Future<void> updateTokens({
    required String access,
    required String refresh,
  }) async {
    accessToken.value = access;
    refreshToken.value = refresh;
    await _secureStorage.write(StorageKeys.accessToken, access);
    await _secureStorage.write(StorageKeys.refreshToken, refresh);
  }

  Future<void> clear() async {
    accessToken.value = null;
    refreshToken.value = null;
    profile.value = null;
    await _secureStorage.delete(StorageKeys.accessToken);
    await _secureStorage.delete(StorageKeys.refreshToken);
    await _localStorage.remove(StorageKeys.profileCache);
  }
}
