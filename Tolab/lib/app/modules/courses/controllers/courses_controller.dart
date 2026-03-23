import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/dto/pagination_query_dto.dart';
import '../../../data/models/course_model.dart';
import '../../../data/repositories/courses_repository.dart';

class CoursesController extends GetxController {
  CoursesController(this._repository);

  final CoursesRepository _repository;
  final ScrollController scrollController = ScrollController();

  final RxList<CourseModel> courses = <CourseModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isFetchingMore = false.obs;
  final RxString error = ''.obs;

  int _page = 1;
  bool _hasMore = true;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_handleScroll);
    loadCourses();
  }

  Future<void> loadCourses({bool refresh = false, String? search}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
      courses.clear();
    }

    if (!_hasMore && !refresh) return;

    isLoading.value = _page == 1;
    isFetchingMore.value = _page > 1;
    error.value = '';

    final result = await _repository.list(
      PaginationQueryDto(page: _page, perPage: 10, search: search),
    );

    result.when(
      success: (data) {
        if (_page == 1) {
          courses.assignAll(data.items);
        } else {
          courses.addAll(data.items);
        }
        _hasMore = data.hasMore;
        _page++;
      },
      failure: (failure) => error.value = failure.message,
    );

    isLoading.value = false;
    isFetchingMore.value = false;
  }

  void _handleScroll() {
    if (scrollController.position.pixels >
        scrollController.position.maxScrollExtent - 280) {
      loadCourses();
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
