import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/localization_manager.dart';
import '../../../core/ui/tokens/color_tokens.dart';
import '../../../core/ui/widgets/university_widgets.dart';
import 'widgets/auth_field_label.dart';
import 'widgets/auth_glass_card.dart';
import 'widgets/auth_hero_panel.dart';
import 'widgets/auth_info_banner.dart';
import 'widgets/auth_input_decoration.dart';
import 'widgets/auth_responsive_layout.dart';
import 'widgets/auth_screen_background.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegex.hasMatch(value)) return 'Invalid email format';
    return null;
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('forget_password'.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: AuthScreenBackground(
        bubbles: const [
          AuthBackgroundBubble(
            top: -70,
            right: -10,
            size: 200,
            colors: [Color(0xFF7AB6FF), Color(0xFF2A67F6)],
          ),
          AuthBackgroundBubble(
            bottom: -60,
            left: -40,
            size: 170,
            colors: [Color(0xFFB7D6FF), Color(0xFF77A7FF)],
          ),
        ],
        child: AuthResponsiveLayout(
          heroBuilder: (compact) =>
              _ForgetPasswordHeroPanel(compact: compact),
          form: _ForgetPasswordFormCard(
            formKey: _formKey,
            emailController: emailController,
            validateEmail: _validateEmail,
          ),
        ),
      ),
    );
  }
}

class _ForgetPasswordHeroPanel extends StatelessWidget {
  final bool compact;

  const _ForgetPasswordHeroPanel({required this.compact});

  @override
  Widget build(BuildContext context) {
    return AuthHeroPanel(
      compact: compact,
      badgeIcon: Icons.lock_reset_rounded,
      badgeLabel: 'Password recovery',
      title: 'Recover access securely',
      subtitle:
          'Enter your university email and we will send a verification code to continue resetting your password.',
      features: const [
        AuthHeroFeature(
          icon: Icons.mark_email_read_rounded,
          label: 'Email verification',
        ),
        AuthHeroFeature(icon: Icons.shield_rounded, label: 'Secure recovery'),
        AuthHeroFeature(icon: Icons.bolt_rounded, label: 'Fast access'),
      ],
    );
  }
}

class _ForgetPasswordFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final String? Function(String?) validateEmail;

  const _ForgetPasswordFormCard({
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
