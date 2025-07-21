// lib/auth/pages/forgot_password_page.dart

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:tolab/core/services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  String? message;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('استعادة كلمة المرور')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'أدخل بريدك الإلكتروني',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();

                if (email.isEmpty) {
                  setState(() {
                    message = 'الرجاء إدخال بريد إلكتروني.';
                  });
                  return;
                }

                try {
                  await AuthService.sendResetPassword(email);

                  setState(() {
                    message =
                        '✅ تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني.';
                  });

                  // الانتقال إلى صفحة التحقق
                  Future.delayed(const Duration(seconds: 1), () {
                    Navigator.pushNamed(
                      context,
                      '/verify-code',
                    ); // أو استخدم push:
                    // Navigator.push(context, MaterialPageRoute(builder: (_) => VerifyPage()));
                  });
                } catch (e) {
                  setState(() {
                    message = '❌ حدث خطأ أثناء الإرسال: ${e.toString()}';
                  });
                }
              },
              child: const Text('إرسال الرابط'),
            ),

            const SizedBox(height: 10),
            if (message != null)
              Text(
                message!,
                style: TextStyle(
                  color: message!.contains('خطأ') ? Colors.red : Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
