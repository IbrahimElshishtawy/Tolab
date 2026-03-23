import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/auth_responsive_layout.dart';
import 'widgets/auth_screen_background.dart';
import 'widgets/verification_code/verification_code_form_card.dart';
import 'widgets/verification_code/verification_code_hero_panel.dart';

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
          heroBuilder: (compact) => VerificationCodeHeroPanel(
            compact: compact,
            timerText: _timerText,
          ),
          form: VerificationCodeFormCard(
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
