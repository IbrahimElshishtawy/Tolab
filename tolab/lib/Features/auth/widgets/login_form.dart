// lib/Features/auth/widgets/login_form.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tolab/Features/auth/controllers/login_controller.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    loadSavedEmailAndPassword();
  }

  Future<void> loadSavedEmailAndPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('saved_email');
    final password = prefs.getString('saved_password');
    final rememberMe = prefs.getBool('remember_me') ?? false;

    final controller = Provider.of<LoginController>(context, listen: false);
    if (rememberMe) {
      controller.emailController.text = email ?? '';
      controller.passwordController.text = password ?? '';
      controller.rememberMe = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<LoginController>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: controller.passwordController,
          obscureText: !isPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () => setState(() {
                isPasswordVisible = !isPasswordVisible;
              }),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
          ),
        ),
        Row(
          children: [
            Checkbox(
              value: controller.rememberMe,
              onChanged: (value) => controller.toggleRememberMe(value ?? false),
            ),
            const Text("Remember me"),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 50,
          child: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: () async {
                    final success = await controller.login(
                      context,
                      email: controller.emailController.text.trim(),
                      password: controller.passwordController.text.trim(),
                    );

                    if (!context.mounted) return;

                    if (success) {
                      // حفظ البيانات إذا تم تفعيل "Remember me"
                      final prefs = await SharedPreferences.getInstance();
                      if (controller.rememberMe) {
                        await prefs.setString(
                          'saved_email',
                          controller.emailController.text.trim(),
                        );
                        await prefs.setString(
                          'saved_password',
                          controller.passwordController.text.trim(),
                        );
                        await prefs.setBool('remember_me', true);
                      } else {
                        await prefs.remove('saved_email');
                        await prefs.remove('saved_password');
                        await prefs.setBool('remember_me', false);
                      }

                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            controller.errorMessage ?? "Login failed",
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: isDark
                        ? const Color(0xFF1E88E5)
                        : const Color.fromARGB(255, 14, 28, 226),
                  ),
                  child: const Text('Login', style: TextStyle(fontSize: 20)),
                ),
        ),
      ],
    );
  }
}
