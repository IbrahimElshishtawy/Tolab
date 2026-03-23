import '../../../core/constants/api_constants.dart';
import '../../../data/datasources/base_remote_data_source.dart';
import '../../../data/models/user_model.dart';
import '../models/auth_session_model.dart';
import '../models/login_request_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._remote);

  final BaseRemoteDataSource _remote;

  Future<AuthSessionModel> login(LoginRequestModel request) async {
    final envelope = await _remote.post<AuthSessionModel>(
      ApiConstants.authLogin,
      body: request.toJson(),
      skipAuth: true,
      parser: (raw) => AuthSessionModel.fromJson(raw as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  Future<UserModel> me() async {
    final envelope = await _remote.get<UserModel>(
      ApiConstants.me,
      parser: (raw) => UserModel.fromJson(raw as Map<String, dynamic>),
    );
    return envelope.data!;
  }

  Future<void> logout(String refreshToken) async {
    await _remote.post<bool>(
      ApiConstants.authLogout,
      body: {'refresh_token': refreshToken},
      parser: (_) => true,
    );
  }
}
