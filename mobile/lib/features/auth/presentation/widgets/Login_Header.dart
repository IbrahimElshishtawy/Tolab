// ignore_for_file: file_names

import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تسجيل الدخول',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'سجّل دخولك باستخدام حساب Microsoft الجامعي.\n'
          'سيتم تحويلك لإدخال كلمة المرور بأمان.',
          style: TextStyle(fontSize: 13, height: 1.6, color: Colors.white70),
        ),
      ],
    );
  }
}
