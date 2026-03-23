import 'package:get/get.dart';

import '../../../data/models/comment_model.dart';
import '../../../data/repositories/group_repository.dart';

class PostDetailsController extends GetxController {
  PostDetailsController(this._repository);

  final GroupRepository _repository;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxList<CommentModel> comments = <CommentModel>[].obs;

  String get groupId => Get.arguments['groupId'].toString();
  String get postId => Get.arguments['postId'].toString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final result = await _repository.comments(groupId, postId);
    result.when(
      success: comments.assignAll,
      failure: (failure) => error.value = failure.message,
    );
    isLoading.value = false;
  }
}
