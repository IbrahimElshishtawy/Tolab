import 'package:get/get.dart';

import '../../../data/dto/pagination_query_dto.dart';
import '../../../data/models/notification_item_model.dart';
import '../../../data/repositories/notifications_repository.dart';

class NotificationsController extends GetxController {
  NotificationsController(this._repository);

  final NotificationsRepository _repository;

  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxList<NotificationItemModel> items = <NotificationItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    final result = await _repository.list(
      const PaginationQueryDto(perPage: 20),
    );
    result.when(
      success: (data) => items.assignAll(data.items),
      failure: (failure) => error.value = failure.message,
    );
    isLoading.value = false;
  }
}
