import 'package:get/get.dart';

import '../../../core/services/session_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/profile_repository.dart';

class ProfileController extends GetxController {
  ProfileController(this._repository, this._sessionService);

  final ProfileRepository _repository;
  final SessionService _sessionService;

  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final Rxn<UserModel> user = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    user.value = _sessionService.currentUser.value;
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    final result = await _repository.fetch();
    result.when(
      success: (data) {
        user.value = data;
        _sessionService.updateUser(data);
      },
      failure: (failure) => error.value = failure.message,
    );
    isLoading.value = false;
  }
}
