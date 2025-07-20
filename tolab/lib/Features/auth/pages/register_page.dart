import 'package:flutter/material.dart';
import 'package:tolab/Features/auth/widgets/register_form.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(title: const Text("إنشاء حساب"), centerTitle: true),
      body: const RegisterForm(),
    );
  }
}
