import 'package:get/get.dart';

import '../../../core/utils/debouncer.dart';
import '../../../data/dto/pagination_query_dto.dart';
import '../../../data/models/course_model.dart';
import '../../../data/repositories/courses_repository.dart';

class SearchController extends GetxController {
  SearchController(this._repository);

  final CoursesRepository _repository;
  final Debouncer _debouncer = Debouncer();

  final RxString query = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<CourseModel> results = <CourseModel>[].obs;

  void onQueryChanged(String value) {
    query.value = value;
    _debouncer.run(() => search(value));
  }

  Future<void> search(String value) async {
    if (value.trim().isEmpty) {
      results.clear();
      return;
    }

    isLoading.value = true;
    final result = await _repository.list(
      PaginationQueryDto(perPage: 10, search: value.trim()),
    );
    result.when(
      success: (data) => results.assignAll(data.items),
      failure: (_) => results.clear(),
    );
    isLoading.value = false;
  }

  @override
  void onClose() {
    _debouncer.dispose();
    super.onClose();
  }
}
