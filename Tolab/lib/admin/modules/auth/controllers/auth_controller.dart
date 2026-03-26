import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/session_service.dart';
import '../../../routes/app_routes.dart';
import '../models/login_request_model.dart';
import '../repositories/auth_repository.dart';

class AuthController extends GetxController {
  AuthController(this._repository, this._sessionService);

  final AuthRepository _repository;
  final SessionService _sessionService;
  final emailController = TextEditingController(text: 'admin@tolab.edu');
  final passwordController = TextEditingController(text: '12345678');
  final isLoading = false.obs;
  final obscurePassword = true.obs;

  Future<void> login() async {
    try {
      isLoading.value = true;
      final session = await _repository.login(
        LoginRequestModel(
          email: emailController.text.trim(),
          password: passwordController.text,
        ),
      );
      await _sessionService.saveSession(
        access: session.accessToken,
        refresh: session.refreshToken,
        user: session.profile,
      );
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (error) {
      Get.snackbar('Login failed', error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void togglePassword() {
    obscurePassword.toggle();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
