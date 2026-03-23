import 'package:get/get.dart';

import '../../../data/models/course_model.dart';
import '../../../data/repositories/courses_repository.dart';

class CourseDetailController extends GetxController {
  CourseDetailController(this._repository);

  final CoursesRepository _repository;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final Rxn<CourseModel> course = Rxn<CourseModel>();

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

    isLoading.value = true;
    final result = await _repository.details(id);
    result.when(
      success: (data) => course.value = data,
      failure: (failure) => error.value = failure.message,
    );
    isLoading.value = false;
  }
}
