import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/colors/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/values/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: context.isDark ? AppColors.darkGlow : AppColors.pageGlow,
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: context.isMobile
                    ? _LoginCard(controller: controller)
                    : Row(
                        children: [
                          const Expanded(child: _HeroPanel()),
                          const SizedBox(width: AppSpacing.xl),
                          Expanded(child: _LoginCard(controller: controller)),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'University control,\nrefined.',
            style: context.text.displayMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Manage students, faculty, schedules, notifications, and system settings from one premium admin workspace.',
            style: context.text.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({required this.controller});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sign in', style: context.text.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text('Use the admin credentials to access the dashboard.'),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            controller: controller.emailController,
            labelText: 'Email',
            prefixIcon: Icons.alternate_email_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          Obx(
            () => AppTextField(
              controller: controller.passwordController,
              labelText: 'Password',
              prefixIcon: Icons.lock_rounded,
              obscureText: controller.obscurePassword.value,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Obx(
            () => AppButton(
              label: 'Continue',
              icon: Icons.arrow_forward_rounded,
              isLoading: controller.isLoading.value,
              onPressed: controller.login,
            ),
          ),
        ],
      ),
    );
  }
}
