import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/ui/tokens/color_tokens.dart';
import '../../../../../core/ui/widgets/university_widgets.dart';
import '../auth_glass_card.dart';
import '../auth_info_banner.dart';
import '../verification_code_digit_field.dart';

class VerificationCodeFormCard extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final String timerText;
  final bool canResend;
  final void Function(int index, String value) onDigitChanged;
  final VoidCallback onResend;
  final VoidCallback onSubmit;

  const VerificationCodeFormCard({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.timerText,
    required this.canResend,
    required this.onDigitChanged,
    required this.onResend,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return AuthGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _VerificationCodeHeader(),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              controllers.length,
              (index) => VerificationCodeDigitField(
                controller: controllers[index],
                focusNode: focusNodes[index],
                onChanged: (value) => onDigitChanged(index, value),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Code expires in: $timerText',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.grey900,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: canResend ? onResend : null,
            child: const Text('Resend code'),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'Check',
            icon: Icons.arrow_forward_rounded,
            onPressed: onSubmit,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Back to email step'),
          ),
          const SizedBox(height: 18),
          const AuthInfoBanner(
            text:
                'If you did not receive the email, wait for the timer to finish and request a new code.',
          ),
        ],
      ),
    );
  }
}

class _VerificationCodeHeader extends StatelessWidget {
  const _VerificationCodeHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.mark_email_read_rounded, size: 52, color: AppColors.primary),
        SizedBox(height: 14),
        Text(
          'Verification Code',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.grey900,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Enter the 4-digit code sent to your email.',
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
