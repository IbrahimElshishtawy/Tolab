import 'package:get/get.dart';

import '../../../data/models/course_content_model.dart';
import '../../../data/repositories/courses_repository.dart';

class CourseContentController extends GetxController {
  CourseContentController(this._repository);

  final CoursesRepository _repository;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final Rxn<CourseContentModel> content = Rxn<CourseContentModel>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final id = Get.parameters['id'] ?? Get.arguments?['id']?.toString() ?? '';
    if (id.isEmpty) {
      error.value = 'Course id is missing';
      isLoading.value = false;
      return;
    }

    final result = await _repository.content(id);
    result.when(
      success: (data) => content.value = data,
      failure: (failure) => error.value = failure.message,
    );
    isLoading.value = false;
  }
}
