import 'package:get/get.dart';

import '../../../data/models/group_model.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/post_model.dart';
import '../../../data/repositories/group_repository.dart';

class GroupController extends GetxController {
  GroupController(this._repository);

  final GroupRepository _repository;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final Rxn<GroupModel> group = Rxn<GroupModel>();
  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxList<MessageModel> messages = <MessageModel>[].obs;

  String get groupId =>
      Get.parameters['groupId'] ?? Get.arguments?['groupId']?.toString() ?? '1';

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = '';

    final groupResult = await _repository.details(groupId);
    final postsResult = await _repository.posts(groupId);
    final messagesResult = await _repository.messages(groupId);

    groupResult.when(
      success: (data) => group.value = data,
      failure: (failure) => error.value = failure.message,
    );
    postsResult.when(
      success: posts.assignAll,
      failure: (failure) =>
          error.value = error.value.isEmpty ? failure.message : error.value,
    );
    messagesResult.when(
      success: messages.assignAll,
      failure: (failure) =>
          error.value = error.value.isEmpty ? failure.message : error.value,
    );

    isLoading.value = false;
  }
}
