import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/session_service.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../models/login_request_model.dart';
import '../repositories/auth_repository.dart';

class AuthController extends GetxController {
  AuthController(this._repository, this._sessionService);

  final AuthRepository _repository;
  final SessionService _sessionService;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  UserModel? get currentUser => _sessionService.currentUser.value;

  String? validateEmail(String? value) => Validators.email(value);
  String? validatePassword(String? value) => Validators.password(value);

  Future<void> login() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    isLoading.value = true;
    final result = await _repository.login(
      LoginRequestModel(
        email: emailController.text.trim(),
        password: passwordController.text,
      ),
    );
    isLoading.value = false;

    result.when(
      success: (_) => Get.offAllNamed(AppRoutes.shell),
      failure: (failure) => Get.snackbar(
        'Login failed',
        failure.message,
        snackPosition: SnackPosition.BOTTOM,
      ),
    );
  }

  Future<void> logout() async {
    isLoading.value = true;
    final result = await _repository.logout();
    isLoading.value = false;

    result.when(
      success: (_) => Get.offAllNamed(AppRoutes.login),
      failure: (_) => Get.offAllNamed(AppRoutes.login),
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
