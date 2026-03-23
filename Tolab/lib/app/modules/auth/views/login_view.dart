import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/animations/reveal_up.dart';
import '../../../core/values/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../routes/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../widgets/login_hero_panel.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      safeAreaTop: false,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                const RevealUp(child: LoginHeroPanel()),
                const SizedBox(height: AppSpacing.lg),
                RevealUp(
                  child: GlassPanel(
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sign in with your university account.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppTextField(
                            controller: controller.emailController,
                            label: 'Email',
                            hintText: 'student@university.edu',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: controller.validateEmail,
                            autofillHints: const [
                              AutofillHints.username,
                              AutofillHints.email,
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Obx(
                            () => AppTextField(
                              controller: controller.passwordController,
                              label: 'Password',
                              hintText: 'Enter your password',
                              obscureText: controller.obscurePassword.value,
                              textInputAction: TextInputAction.done,
                              validator: controller.validatePassword,
                              autofillHints: const [AutofillHints.password],
                              suffix: IconButton(
                                onPressed: controller.obscurePassword.toggle,
                                icon: Icon(
                                  controller.obscurePassword.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                              onFieldSubmitted: (_) => controller.login(),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () =>
                                  Get.toNamed(AppRoutes.forgotPassword),
                              child: const Text('Forgot password?'),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Obx(
                            () => AppButton.primary(
                              label: 'Login',
                              isLoading: controller.isLoading.value,
                              onPressed: controller.login,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
