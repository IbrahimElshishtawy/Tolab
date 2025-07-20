// lib/auth/pages/forgot_password_page.dart

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
              decoration: const InputDecoration(
                labelText: 'أدخل بريدك الإلكتروني',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await AuthService.sendResetPassword(
                    emailController.text.trim(),
                  );
                  setState(() {
                    message = 'تم إرسال رابط الاستعادة إلى بريدك.';
                  });
                } catch (e) {
                  setState(() {
                    message = 'حدث خطأ: ${e.toString()}';
                  });
                }
              },
              child: const Text('إرسال الرابط'),
            ),
            if (message != null) ...[
              const SizedBox(height: 10),
              Text(
                message!,
                style: TextStyle(
                  color: message!.startsWith('حدث خطأ')
                      ? Colors.red
                      : Colors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
