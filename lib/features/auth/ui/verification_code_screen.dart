import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/tokens/color_tokens.dart';
import '../../../core/ui/tokens/radius_tokens.dart';
import '../../../core/ui/widgets/university_widgets.dart';
import 'widgets/auth_glass_card.dart';
import 'widgets/auth_info_banner.dart';
import 'widgets/auth_responsive_layout.dart';
import 'widgets/auth_screen_background.dart';
import 'widgets/verification_code_digit_field.dart';

class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({super.key});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  int _timerSeconds = 120;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timerSeconds = 120);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _timerText {
    final minutes = _timerSeconds ~/ 60;
    final seconds = _timerSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _handleDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _submitCode(BuildContext context) {
    final code = _controllers.map((e) => e.text).join();
    if (code.length == 4) {
      context.push('/reset-password');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter the full code')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Code')),
      body: AuthScreenBackground(
        bubbles: const [
          AuthBackgroundBubble(
            top: -75,
            right: -20,
            size: 210,
            colors: [Color(0xFF7AB6FF), Color(0xFF2A67F6)],
          ),
          AuthBackgroundBubble(
            bottom: -60,
            left: -25,
            size: 170,
            colors: [Color(0xFFB7D6FF), Color(0xFF77A7FF)],
          ),
        ],
        child: AuthResponsiveLayout(
          heroBuilder: (compact) => _VerificationCodeHeroPanel(
            compact: compact,
            timerText: _timerText,
          ),
          form: _VerificationCodeFormCard(
            controllers: _controllers,
            focusNodes: _focusNodes,
            timerText: _timerText,
            canResend: _timerSeconds == 0,
            onDigitChanged: _handleDigitChanged,
            onResend: _startTimer,
            onSubmit: () => _submitCode(context),
          ),
        ),
      ),
    );
  }
}

class _VerificationCodeHeroPanel extends StatelessWidget {
  final bool compact;
  final String timerText;

  const _VerificationCodeHeroPanel({
    required this.compact,
    required this.timerText,
  });

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
                Icon(Icons.verified_rounded, color: AppColors.primary, size: 18),
                SizedBox(width: 8),
                Text(
                  'Email verification',
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
            'Confirm your code',
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
            'Enter the 4-digit code sent to your email. The current code expires in $timerText.',
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

class _VerificationCodeFormCard extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final String timerText;
  final bool canResend;
  final void Function(int index, String value) onDigitChanged;
  final VoidCallback onResend;
  final VoidCallback onSubmit;

  const _VerificationCodeFormCard({
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
