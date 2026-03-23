import 'package:get/get.dart';

import '../../../core/services/session_service.dart';
import '../../../core/utils/result.dart';
import '../../../data/repositories/base_repository.dart';
import '../../../data/models/user_model.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_session_model.dart';
import '../models/login_request_model.dart';

class AuthRepository extends GetxService with BaseRepository {
  AuthRepository({
    required AuthRemoteDataSource remoteDataSource,
    required SessionService sessionService,
  }) : _remoteDataSource = remoteDataSource,
       _sessionService = sessionService;

  final AuthRemoteDataSource _remoteDataSource;
  final SessionService _sessionService;

  Future<Result<AuthSessionModel>> login(LoginRequestModel request) {
    return guard(() async {
      final session = await _remoteDataSource.login(request);
      await _sessionService.saveSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        user: session.user,
      );
      return session;
    });
  }

  Future<Result<UserModel>> restoreUser() {
    return guard(() async {
      final user = await _remoteDataSource.me();
      await _sessionService.updateUser(user);
      return user;
    });
  }

  Future<Result<void>> logout() {
    return guard(() async {
      final refreshToken = _sessionService.refreshToken;
      if (refreshToken?.isNotEmpty == true) {
        await _remoteDataSource.logout(refreshToken!);
      }
      await _sessionService.clearSession(force: true);
    });
  }
}
