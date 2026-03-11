import 'package:flutter/material.dart';

import '../../../core/localization/localization_manager.dart';
import 'widgets/auth_responsive_layout.dart';
import 'widgets/auth_screen_background.dart';
import 'widgets/forget_password/forget_password_form_card.dart';
import 'widgets/forget_password/forget_password_hero_panel.dart';

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
          heroBuilder: (compact) => ForgetPasswordHeroPanel(compact: compact),
          form: ForgetPasswordFormCard(
            formKey: _formKey,
            emailController: emailController,
            validateEmail: _validateEmail,
          ),
        ),
      ),
    );
  }
}
