import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tolab/Features/auth/controllers/login_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<LoginController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller.emailController,
              decoration: const InputDecoration(
                labelText: 'الرقم الجامعي',
                hintText: 'مثال: UG_31159678',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.passwordController,
              obscureText: !controller.showPassword,
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.showPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: controller.rememberMe,
                  onChanged: controller.toggleRememberMe,
                ),
                const Text('تذكرني'),
              ],
            ),
            if (controller.errorMessage != null &&
                controller.errorMessage!.isNotEmpty)
              Text(
                controller.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.isLoading
                  ? null
                  : () => controller.login(context),
              child: controller.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('تسجيل الدخول'),
            ),
          ],
        ),
      ),
    );
  }
}
