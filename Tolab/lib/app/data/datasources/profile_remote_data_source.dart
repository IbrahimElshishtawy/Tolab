import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import 'base_remote_data_source.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._remote);

  final BaseRemoteDataSource _remote;

  Future<UserModel> fetch() async {
    final envelope = await _remote.get<UserModel>(
      ApiConstants.profile,
      parser: (raw) => UserModel.fromJson(raw as Map<String, dynamic>),
    );
    return envelope.data!;
  }
}
