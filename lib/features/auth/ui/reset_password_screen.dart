import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/tokens/color_tokens.dart';
import '../../../core/ui/tokens/radius_tokens.dart';
import '../../../core/ui/widgets/university_widgets.dart';
import 'widgets/auth_field_label.dart';
import 'widgets/auth_glass_card.dart';
import 'widgets/auth_info_banner.dart';
import 'widgets/auth_input_decoration.dart';
import 'widgets/auth_responsive_layout.dart';
import 'widgets/auth_screen_background.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: AuthScreenBackground(
        bubbles: const [
          AuthBackgroundBubble(
            top: -80,
            right: -25,
            size: 210,
            colors: [Color(0xFF7AB6FF), Color(0xFF2A67F6)],
          ),
          AuthBackgroundBubble(
            bottom: -70,
            left: -35,
            size: 180,
            colors: [Color(0xFFB7D6FF), Color(0xFF77A7FF)],
          ),
        ],
        child: AuthResponsiveLayout(
          heroBuilder: (compact) => _ResetPasswordHeroPanel(compact: compact),
          form: _ResetPasswordFormCard(
            formKey: _formKey,
            passwordController: passwordController,
            confirmPasswordController: confirmPasswordController,
            obscurePassword: _obscurePassword,
            obscureConfirmPassword: _obscureConfirmPassword,
            onTogglePassword: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            onToggleConfirmPassword: () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword,
            ),
          ),
        ),
      ),
    );
  }
}

class _ResetPasswordHeroPanel extends StatelessWidget {
  final bool compact;

  const _ResetPasswordHeroPanel({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        right: compact ? 0 : 24,
        top: compact ? 8 : 56,
        bottom: compact ? 8 : 56,
      ),
      child: Column(
        crossAxisAlignment:
            compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: AppRadius.rXl,
              border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.key_rounded, color: AppColors.primary, size: 18),
                SizedBox(width: 8),
                Text(
                  'Set a new password',
                  style: TextStyle(
                    color: AppColors.grey800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: compact ? 18 : 28),
          Text(
            'Create a secure password',
            textAlign: compact ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: compact ? 30 : 42,
              fontWeight: FontWeight.w800,
              height: 1.05,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Choose a strong password that you have not used before. This will be the new sign-in password for your university account.',
            textAlign: compact ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: compact ? 15 : 17,
              height: 1.6,
              color: AppColors.grey700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResetPasswordFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;

  const _ResetPasswordFormCard({
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
