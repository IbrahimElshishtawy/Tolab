import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/localization_manager.dart';
import '../../../core/ui/tokens/color_tokens.dart';
import '../../../core/ui/tokens/radius_tokens.dart';
import '../../../core/ui/widgets/university_widgets.dart';

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
              top: -70,
              right: -10,
              child: _buildGlowBubble(
                size: 200,
                colors: const [Color(0xFF7AB6FF), Color(0xFF2A67F6)],
              ),
            ),
            Positioned(
              bottom: -60,
              left: -40,
              child: _buildGlowBubble(
                size: 170,
                colors: const [Color(0xFFB7D6FF), Color(0xFF77A7FF)],
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
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
                                  Expanded(child: _buildFormCard(context)),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildHeroPanel(compact: true),
                                  const SizedBox(height: 20),
                                  _buildFormCard(context),
                                ],
                              ),
                      ),
                    ),
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
                Icon(Icons.lock_reset_rounded,
                    color: AppColors.primary, size: 18),
                SizedBox(width: 8),
                Text(
                  'Password recovery',
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
            'Recover access securely',
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
            'Enter your university email and we will send a verification code to continue resetting your password.',
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
                icon: Icons.mark_email_read_rounded,
                label: 'Email verification',
              ),
              _FeatureChip(
                icon: Icons.shield_rounded,
                label: 'Secure recovery',
              ),
              _FeatureChip(
                icon: Icons.bolt_rounded,
                label: 'Fast access',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
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
                Text(
                  'Use your official academic email to receive a one-time verification code.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'University Email',
                  style: TextStyle(
                    color: AppColors.grey800,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'name@university.edu',
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.9),
                    prefixIcon: const Icon(
                      Icons.alternate_email_rounded,
                      color: AppColors.grey500,
                    ),
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
                      borderSide: const BorderSide(
                        color: AppColors.secondary,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: AppRadius.rL,
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: AppRadius.rL,
                      borderSide: const BorderSide(
                        color: AppColors.error,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Send Verification Code',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
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
                          'The verification code will be used in the next step to confirm account ownership.',
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
              ],
            ),
          ),
        ),
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
