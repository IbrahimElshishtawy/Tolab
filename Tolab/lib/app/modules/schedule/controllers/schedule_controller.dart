import 'package:get/get.dart';

import '../../../data/models/schedule_event_model.dart';
import '../../../data/repositories/schedule_repository.dart';

class ScheduleController extends GetxController {
  ScheduleController(this._repository);

  final ScheduleRepository _repository;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxList<ScheduleEventModel> events = <ScheduleEventModel>[].obs;
  final RxString selectedWeek = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({String? week}) async {
    if (week != null) selectedWeek.value = week;
    isLoading.value = true;
    final result = await _repository.list(week: selectedWeek.value);
    result.when(
      success: events.assignAll,
      failure: (failure) => error.value = failure.message,
    );
    isLoading.value = false;
  }
}
