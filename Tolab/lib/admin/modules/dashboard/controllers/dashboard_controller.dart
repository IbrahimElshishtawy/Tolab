import 'package:get/get.dart';

import '../../../data/models/admin_models.dart';
import '../../../data/repositories/admin/dashboard_repository.dart';

class DashboardController extends GetxController {
  DashboardController(this._repository);

  final DashboardRepository _repository;
  final isLoading = false.obs;
  final summary = Rxn<DashboardSummaryModel>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    summary.value = await _repository.fetchSummary();
    isLoading.value = false;
  }
}
