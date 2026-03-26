import 'package:get/get.dart';

import '../../../core/utils/debouncer.dart';
import '../../../data/models/admin_models.dart';
import '../../../data/repositories/admin/admin_resource_repository.dart';

abstract class ManagementController<T extends AdminEntity>
    extends GetxController {
  ManagementController(this.repository);

  final AdminResourceRepository<T> repository;

  final items = <T>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = RxnString();
  final page = 1.obs;
  final total = 0.obs;
  final query = ''.obs;
  final debouncer = Debouncer();
  final int perPage = 10;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load({int pageNumber = 1, String? search}) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final response = await repository.fetch(
        page: pageNumber,
        perPage: perPage,
        search: search ?? query.value,
      );
      items.assignAll(response.items);
      page.value = response.page;
      total.value = response.total;
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String value) {
    query.value = value;
    debouncer(() => load(search: value));
  }

  Future<void> delete(String id) async {
    try {
      isSubmitting.value = true;
      await repository.remove(id);
      await load(search: query.value);
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    debouncer.dispose();
    super.onClose();
  }
}
