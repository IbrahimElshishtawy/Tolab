import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/ui/tokens/color_tokens.dart';
import '../../../../../core/ui/widgets/university_widgets.dart';
import '../auth_field_label.dart';
import '../auth_glass_card.dart';
import '../auth_info_banner.dart';
import '../auth_input_decoration.dart';

class ResetPasswordFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;

  const ResetPasswordFormCard({
    super.key,
    required this.formKey,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
  });

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (value.length < 6) return 'Password too short';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AuthGlassCard(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _ResetPasswordHeader(),
            const SizedBox(height: 28),
            const AuthFieldLabel(text: 'New Password'),
            const SizedBox(height: 10),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              maxLength: 25,
              decoration: buildAuthInputDecoration(
                hintText: 'Enter your new password',
                icon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: AppColors.grey500,
                  ),
                  onPressed: onTogglePassword,
                ),
              ),
              validator: _validatePassword,
            ),
            const SizedBox(height: 20),
            const AuthFieldLabel(text: 'Confirm Password'),
            const SizedBox(height: 10),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: obscureConfirmPassword,
              maxLength: 25,
              decoration: buildAuthInputDecoration(
                hintText: 'Re-enter your password',
                icon: Icons.lock_reset_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: AppColors.grey500,
                  ),
                  onPressed: onToggleConfirmPassword,
                ),
              ),
              validator: _validateConfirmPassword,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Continue',
              icon: Icons.arrow_forward_rounded,
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset successfully'),
                    ),
                  );
                  context.go('/login');
                }
              },
            ),
            const SizedBox(height: 18),
            const AuthInfoBanner(
              text:
                  'Use at least 6 characters and avoid using the same password from other services.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ResetPasswordHeader extends StatelessWidget {
  const _ResetPasswordHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.lock_person_rounded, size: 52, color: AppColors.primary),
        SizedBox(height: 14),
        Text(
          'Reset Password',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.grey900,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Enter your new password below.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.grey600,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
