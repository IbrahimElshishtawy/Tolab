import 'package:flutter/material.dart';

import 'widgets/auth_responsive_layout.dart';
import 'widgets/auth_screen_background.dart';
import 'widgets/reset_password/reset_password_form_card.dart';
import 'widgets/reset_password/reset_password_hero_panel.dart';

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
          heroBuilder: (compact) => ResetPasswordHeroPanel(compact: compact),
          form: ResetPasswordFormCard(
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
