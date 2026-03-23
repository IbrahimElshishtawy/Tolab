import '../../core/utils/result.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/user_model.dart';
import 'base_repository.dart';

class ProfileRepository with BaseRepository {
  ProfileRepository(this._remote);

  final ProfileRemoteDataSource _remote;

  Future<Result<UserModel>> fetch() => guard(() => _remote.fetch());
}
