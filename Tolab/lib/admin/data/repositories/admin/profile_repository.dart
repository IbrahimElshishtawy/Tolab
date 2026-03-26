// ignore_for_file: unused_field

import '../../datasources/admin/admin_resource_remote_data_source.dart';
import '../../models/admin_models.dart';
import '../../models/admin_seed_data.dart';

class ProfileRepository {
  ProfileRepository(this._remoteDataSource);

  final AdminResourceRemoteDataSource _remoteDataSource;

  Future<ProfileModel> getProfile() async => AdminSeedData.profile();
}
