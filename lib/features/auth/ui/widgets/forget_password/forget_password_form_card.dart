import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/localization/localization_manager.dart';
import '../../../../../core/ui/tokens/color_tokens.dart';
import '../../../../../core/ui/widgets/university_widgets.dart';
import '../auth_field_label.dart';
import '../auth_glass_card.dart';
import '../auth_info_banner.dart';
import '../auth_input_decoration.dart';

class ForgetPasswordFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final String? Function(String?) validateEmail;

  const ForgetPasswordFormCard({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.validateEmail,
  });

  @override
  Widget build(BuildContext context) {
    return AuthGlassCard(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _ForgetPasswordHeader(),
            const SizedBox(height: 28),
            const AuthFieldLabel(text: 'University Email'),
            const SizedBox(height: 10),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: buildAuthInputDecoration(
                hintText: 'name@university.edu',
                icon: Icons.alternate_email_rounded,
              ),
              validator: validateEmail,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Send Verification Code',
              icon: Icons.arrow_forward_rounded,
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  context.push('/verify-code');
                }
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondary,
              ),
              child: const Text('Back to login'),
            ),
            const SizedBox(height: 18),
            const AuthInfoBanner(
              text:
                  'The verification code will be used in the next step to confirm account ownership.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ForgetPasswordHeader extends StatelessWidget {
  const _ForgetPasswordHeader();

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
              Icons.password_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'forget_password'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.grey900,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Use your official academic email to receive a one-time verification code.',
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
