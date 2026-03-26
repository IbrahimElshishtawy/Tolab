import 'package:get/get.dart';

import '../../../data/models/admin_models.dart';
import '../../../data/repositories/admin/profile_repository.dart';

class ProfileController extends GetxController {
  ProfileController(this._repository);

  final ProfileRepository _repository;
  final profile = Rxn<ProfileModel>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    profile.value = await _repository.getProfile();
  }
}
