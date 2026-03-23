import 'package:get/get.dart';

import '../../../data/models/grade_item_model.dart';
import '../../../data/repositories/courses_repository.dart';

class GradesController extends GetxController {
  GradesController(this._repository);

  final CoursesRepository _repository;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxList<GradeItemModel> grades = <GradeItemModel>[].obs;

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

    final result = await _repository.grades(id);
    result.when(
      success: grades.assignAll,
      failure: (failure) => error.value = failure.message,
    );
    isLoading.value = false;
  }
}
