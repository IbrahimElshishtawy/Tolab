import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/admin_models.dart';
import '../../../data/repositories/admin/notifications_repository.dart';

class NotificationsController extends GetxController {
  NotificationsController(this._repository);

  final NotificationsRepository _repository;
  final items = <AdminNotificationModel>[].obs;
  final isLoading = false.obs;
  final titleController = TextEditingController();
  final bodyController = TextEditingController();
  final audience = 'All Users'.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    items.assignAll(await _repository.getNotifications());
    isLoading.value = false;
  }

  Future<void> markAllRead() async {
    await _repository.markAllRead();
    await load();
  }

  Future<void> broadcast() async {
    await _repository.broadcast(
      title: titleController.text.trim(),
      body: bodyController.text.trim(),
      audience: audience.value,
    );
    titleController.clear();
    bodyController.clear();
    await load();
  }
}
