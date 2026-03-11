import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:tolab_fci/redux/app_state.dart';

import '../../../config/env.dart';
import '../../../core/localization/localization_manager.dart';
import '../../../core/routing/role_routing.dart';
import '../../../core/ui/tokens/color_tokens.dart';
import '../../../core/ui/tokens/spacing_tokens.dart';
import '../../../core/ui/widgets/university_widgets.dart';
import '../../../mock/mock_data.dart';
import '../redux/auth_actions.dart';
import '../redux/auth_state.dart';
import 'widgets/auth_field_label.dart';
import 'widgets/auth_glass_card.dart';
import 'widgets/auth_hero_panel.dart';
import 'widgets/auth_info_banner.dart';
import 'widgets/auth_input_decoration.dart';
import 'widgets/auth_responsive_layout.dart';
import 'widgets/auth_screen_background.dart';
import 'widgets/demo_account_chip.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isFormValid = false;

  void _validateForm() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegex.hasMatch(value)) return 'Invalid email format';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password too short';
    return null;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthScreenBackground(
        bubbles: const [
          AuthBackgroundBubble(
            top: -80,
            right: -30,
            size: 220,
            colors: [Color(0xFF7AB6FF), Color(0xFF2A67F6)],
          ),
          AuthBackgroundBubble(
            top: 180,
            left: -70,
            size: 180,
            colors: [Color(0xFFB7D6FF), Color(0xFF77A7FF)],
          ),
        ],
        child: StoreConnector<AppState, AuthState>(
          converter: (store) => store.state.authState,
          onWillChange: (oldState, newState) {
            if (newState.isAuthenticated) {
              context.go(landingRouteForRole(newState.role));
            }
            if (newState.error != null && newState.error != oldState?.error) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(newState.error!)));
            }
          },
          builder: (context, state) {
            return AuthResponsiveLayout(
              heroBuilder: (compact) => _LoginHeroPanel(compact: compact),
              form: _LoginCard(
                formKey: _formKey,
                emailController: emailController,
                passwordController: passwordController,
                isObscurePassword: _obscurePassword,
                isFormValid: _isFormValid,
                isLoading: state.isLoading,
                validateEmail: _validateEmail,
                validatePassword: _validatePassword,
                onFormChanged: _validateForm,
                onTogglePasswordVisibility: () => setState(
                  () => _obscurePassword = !_obscurePassword,
                ),
                onForgotPassword: () => context.push('/forget-password'),
                onLogin: () {
                  StoreProvider.of<AppState>(context).dispatch(
                    LoginAction(
                      emailController.text.trim(),
                      passwordController.text,
                    ),
                  );
                },
                onDemoAccountSelected: (account) {
                  setState(() {
                    emailController.text = account['email'] ?? '';
                    passwordController.text = account['password'] ?? '';
                    _isFormValid = true;
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginHeroPanel extends StatelessWidget {
  final bool compact;

  const _LoginHeroPanel({required this.compact});

  @override
  Widget build(BuildContext context) {
    return AuthHeroPanel(
      compact: compact,
      badgeIcon: Icons.verified_user_rounded,
      badgeLabel: 'University access portal',
      title: 'Welcome back',
      subtitle:
          'Sign in to manage courses, track academic activity, and access your university workspace from one secure place.',
      features: const [
        AuthHeroFeature(
          icon: Icons.auto_awesome_mosaic_rounded,
          label: 'Modern dashboard',
        ),
        AuthHeroFeature(icon: Icons.shield_rounded, label: 'Secure access'),
        AuthHeroFeature(
          icon: Icons.groups_2_rounded,
          label: 'Faculty workflow',
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
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

  const _LoginCard({
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

  const _DemoAccountsSection({required this.onDemoAccountSelected});

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
