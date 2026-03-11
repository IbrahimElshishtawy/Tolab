import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import '../../../redux/app_state.dart';
import '../../../config/env.dart';
import '../redux/auth_actions.dart';
import '../redux/auth_state.dart';
import '../../../core/localization/localization_manager.dart';
import '../../../core/ui/tokens/color_tokens.dart';
import '../../../core/ui/tokens/radius_tokens.dart';
import '../../../core/ui/widgets/university_widgets.dart';
import '../../../core/ui/tokens/spacing_tokens.dart';
import '../../../mock/mock_data.dart';

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF4F8FF),
              Color(0xFFEAF1FF),
              Color(0xFFF9FBFF),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -30,
              child: _buildGlowBubble(
                size: 220,
                colors: const [Color(0xFF7AB6FF), Color(0xFF2A67F6)],
              ),
            ),
            Positioned(
              top: 180,
              left: -70,
              child: _buildGlowBubble(
                size: 180,
                colors: const [Color(0xFFB7D6FF), Color(0xFF77A7FF)],
              ),
            ),
            SafeArea(
              child: StoreConnector<AppState, AuthState>(
                converter: (store) => store.state.authState,
                onWillChange: (oldState, newState) {
                  if (newState.isAuthenticated) {
                    context.go('/home');
                  }
                  if (newState.error != null &&
                      newState.error != oldState?.error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(newState.error!)),
                    );
                  }
                },
                builder: (context, state) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 820;
                      return SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          isWide ? 48 : 20,
                          24,
                          isWide ? 48 : 20,
                          24,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1080),
                            child: isWide
                                ? Row(
                                    children: [
                                      Expanded(child: _buildHeroPanel()),
                                      const SizedBox(width: 28),
                                      Expanded(
                                        child: _buildLoginCard(context, state),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _buildHeroPanel(compact: true),
                                      const SizedBox(height: 20),
                                      _buildLoginCard(context, state),
                                    ],
                                  ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroPanel({bool compact = false}) {
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
                Icon(Icons.verified_user_rounded,
                    color: AppColors.primary, size: 18),
                SizedBox(width: 8),
                Text(
                  'University access portal',
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
            'Welcome back',
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
            'Sign in to manage courses, track academic activity, and access your university workspace from one secure place.',
            textAlign: compact ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: compact ? 15 : 17,
              height: 1.6,
              color: AppColors.grey700,
            ),
          ),
          SizedBox(height: compact ? 18 : 28),
          Wrap(
            alignment: compact ? WrapAlignment.center : WrapAlignment.start,
            spacing: 12,
            runSpacing: 12,
            children: const [
              _FeatureChip(
                icon: Icons.auto_awesome_mosaic_rounded,
                label: 'Modern dashboard',
              ),
              _FeatureChip(
                icon: Icons.shield_rounded,
                label: 'Secure access',
              ),
              _FeatureChip(
                icon: Icons.groups_2_rounded,
                label: 'Faculty workflow',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context, AuthState state) {
    return ClipRRect(
      borderRadius: AppRadius.rXxl,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: AppRadius.rXxl,
            border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 40,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            onChanged: _validateForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                Text(
                  'Use your university account credentials to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                _buildFieldLabel('email_label'.tr()),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  maxLength: 100,
                  decoration: _buildInputDecoration(
                    label: 'name@university.edu',
                    icon: Icons.alternate_email_rounded,
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 10),
                _buildFieldLabel('password_label'.tr()),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  maxLength: 25,
                  decoration: _buildInputDecoration(
                    label: 'Enter your password',
                    icon: Icons.lock_outline_rounded,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: AppColors.grey500,
                      ),
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                    ),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forget-password'),
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
                  isLoading: state.isLoading,
                  onPressed: _isFormValid
                      ? () {
                          StoreProvider.of<AppState>(context).dispatch(
                            LoginAction(
                              emailController.text.trim(),
                              passwordController.text,
                            ),
                          );
                        }
                      : null,
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7FC),
                    borderRadius: AppRadius.rL,
                    border: Border.all(color: const Color(0xFFE0E8F5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Only approved university email accounts can sign in.',
                          style: TextStyle(
                            color: AppColors.grey700,
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (Env.useMock) ...[
                  const SizedBox(height: 18),
                  _buildDemoAccountsSection(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.grey800,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: label,
      counterText: '',
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.9),
      prefixIcon: Icon(icon, color: AppColors.grey500),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.rL,
        borderSide: const BorderSide(color: Color(0xFFDCE4F2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.rL,
        borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.rL,
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.rL,
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  Widget _buildGlowBubble({
    required double size,
    required List<Color> colors,
  }) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: colors),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: 0.18),
              blurRadius: 48,
              spreadRadius: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoAccountsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Demo Accounts',
          style: TextStyle(
            color: AppColors.grey800,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: mockAuthAccounts.map((account) {
            return _DemoAccountChip(
              label: account['label'] ?? '',
              role: account['role'] ?? '',
              onTap: () {
                setState(() {
                  emailController.text = account['email'] ?? '';
                  passwordController.text = account['password'] ?? '';
                  _isFormValid = true;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: AppRadius.rXl,
        border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.grey800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoAccountChip extends StatelessWidget {
  final String label;
  final String role;
  final VoidCallback onTap;

  const _DemoAccountChip({
    required this.label,
    required this.role,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.rL,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F7FC),
            borderRadius: AppRadius.rL,
            border: Border.all(color: const Color(0xFFDCE4F2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.grey900,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                role.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
