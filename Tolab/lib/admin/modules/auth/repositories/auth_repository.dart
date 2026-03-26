import '../../../core/network/api_exception_mapper.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_session_model.dart';
import '../models/login_request_model.dart';

class AuthRepository {
  AuthRepository(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  Future<AuthSessionModel> login(LoginRequestModel request) async {
    try {
      return _remoteDataSource.login(request);
    } catch (error) {
      throw ApiExceptionMapper.map(error);
    }
  }
}
