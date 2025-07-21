// lib/auth/pages/forgot_password_page.dart

// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:tolab/core/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  String? message;
  bool isLoading = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _checkEmailExists(String email) async {
    try {
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(
        email,
      );
      return methods.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _handleSendReset() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        message = 'الرجاء إدخال بريد إلكتروني.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      message = null;
    });

    final exists = await _checkEmailExists(email);

    if (!exists) {
      setState(() {
        message = '❌ هذا البريد الإلكتروني غير مسجل.';
        isLoading = false;
      });
      return;
    }

    try {
      await AuthService.sendResetPassword(email);
      setState(() {
        message = '✅ تم إرسال رابط الاستعادة إلى بريدك الإلكتروني.';
      });

      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushNamed(context, '/verify-code');
    } catch (e) {
      setState(() {
        message = '❌ حدث خطأ أثناء الإرسال: ${e.toString()}';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('استعادة كلمة المرور')),
      body: FadeTransition(
        opacity: _animation,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'أدخل بريدك الإلكتروني',
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email_outlined),
                  fillColor: isDark ? Colors.grey[850] : Colors.grey[200],
                  filled: true,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: isLoading ? null : _handleSendReset,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send),
                label: const Text('إرسال الرابط'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              if (message != null)
                AnimatedOpacity(
                  opacity: 1,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    message!,
                    style: TextStyle(
                      color: message!.contains('❌') ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
