import 'package:flutter/material.dart';

import '../../../../../config/env.dart';
import '../../../../../core/localization/localization_manager.dart';
import '../../../../../core/ui/tokens/color_tokens.dart';
import '../../../../../core/ui/tokens/spacing_tokens.dart';
import '../../../../../core/ui/widgets/university_widgets.dart';
import '../../../../../mock/mock_data.dart';
import '../auth_field_label.dart';
import '../auth_glass_card.dart';
import '../auth_info_banner.dart';
import '../auth_input_decoration.dart';
import '../demo_account_chip.dart';

class LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isObscurePassword;
  final bool isFormValid;
  final bool isLoading;
  final String? Function(String?) validateEmail;
  final String? Function(String?) validatePassword;
  final VoidCallback onFormChanged;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onForgotPassword;
  final VoidCallback onLogin;
  final ValueChanged<Map<String, String>> onDemoAccountSelected;

  const LoginCard({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isObscurePassword,
    required this.isFormValid,
    required this.isLoading,
    required this.validateEmail,
    required this.validatePassword,
    required this.onFormChanged,
    required this.onTogglePasswordVisibility,
    required this.onForgotPassword,
    required this.onLogin,
    required this.onDemoAccountSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AuthGlassCard(
      child: Form(
        key: formKey,
        onChanged: onFormChanged,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _LoginCardHeader(),
            const SizedBox(height: 28),
            AuthFieldLabel(text: 'email_label'.tr()),
            const SizedBox(height: 10),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              maxLength: 100,
              decoration: buildAuthInputDecoration(
                hintText: 'name@university.edu',
                icon: Icons.alternate_email_rounded,
              ),
              validator: validateEmail,
            ),
            const SizedBox(height: 10),
            AuthFieldLabel(text: 'password_label'.tr()),
            const SizedBox(height: 10),
            TextFormField(
              controller: passwordController,
              obscureText: isObscurePassword,
              maxLength: 25,
              decoration: buildAuthInputDecoration(
                hintText: 'Enter your password',
                icon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    isObscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: AppColors.grey500,
                  ),
                  onPressed: onTogglePasswordVisibility,
                ),
              ),
              validator: validatePassword,
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onForgotPassword,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                ),
                child: Text('forget_password'.tr()),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            AppButton(
              text: 'login_btn'.tr(),
              icon: Icons.arrow_forward_rounded,
              isLoading: isLoading,
              onPressed: isFormValid ? onLogin : null,
            ),
            const SizedBox(height: 18),
            const AuthInfoBanner(
              text: 'Only approved university email accounts can sign in.',
            ),
            if (Env.useMock) ...[
              const SizedBox(height: 18),
              _DemoAccountsSection(onDemoAccountSelected: onDemoAccountSelected),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoginCardHeader extends StatelessWidget {
  const _LoginCardHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.35),
                  blurRadius: 26,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'login_title'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.grey900,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Use your university account credentials to continue.',
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

class _DemoAccountsSection extends StatelessWidget {
  final ValueChanged<Map<String, String>> onDemoAccountSelected;

  const _DemoAccountsSection({
    required this.onDemoAccountSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AuthFieldLabel(text: 'Demo Accounts'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: mockAuthAccounts
              .map(
                (account) => DemoAccountChip(
                  label: account['label'] ?? '',
                  role: account['role'] ?? '',
                  onTap: () => onDemoAccountSelected(account),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
