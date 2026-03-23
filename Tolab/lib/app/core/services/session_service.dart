import 'package:get/get.dart';

import '../../data/models/user_model.dart';
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

  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool isAuthenticated = false.obs;

  String? accessToken;
  String? refreshToken;

  Future<SessionService> init() async {
    accessToken = await _secureStorage.read(StorageKeys.accessToken);
    refreshToken = await _secureStorage.read(StorageKeys.refreshToken);
    final rawUser = _localStorage.readString(StorageKeys.currentUser);
    if (rawUser?.isNotEmpty == true) {
      currentUser.value = UserModel.fromRawJson(rawUser!);
    }
    isAuthenticated.value = accessToken?.isNotEmpty == true;
    return this;
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required UserModel user,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    currentUser.value = user;
    isAuthenticated.value = true;

    await _secureStorage.write(StorageKeys.accessToken, accessToken);
    await _secureStorage.write(StorageKeys.refreshToken, refreshToken);
    await _localStorage.writeString(StorageKeys.currentUser, user.toRawJson());
  }

  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    isAuthenticated.value = true;

    await _secureStorage.write(StorageKeys.accessToken, accessToken);
    await _secureStorage.write(StorageKeys.refreshToken, refreshToken);
  }

  Future<void> updateUser(UserModel user) async {
    currentUser.value = user;
    await _localStorage.writeString(StorageKeys.currentUser, user.toRawJson());
  }

  Future<void> clearSession({bool force = false}) async {
    accessToken = null;
    refreshToken = null;
    currentUser.value = null;
    isAuthenticated.value = false;

    await _secureStorage.delete(StorageKeys.accessToken);
    await _secureStorage.delete(StorageKeys.refreshToken);
    await _localStorage.remove(StorageKeys.currentUser);
  }
}
