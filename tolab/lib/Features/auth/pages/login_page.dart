// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tolab/Features/auth/controllers/login_controller.dart';
import 'package:tolab/core/services/auth_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => LoginController(),
      child: Consumer<LoginController>(
        builder: (context, controller, _) {
          return Scaffold(
            body: Stack(
              children: [
                /// ✅ الشعار في الأعلى
                Positioned(
                  top: 145,
                  left: MediaQuery.of(context).size.width / 2 - 75,
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/image_App/Tolab.png',
                        width: 150,
                        height: 150,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ToLab',
                        style: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color.fromARGB(236, 13, 20, 217),
                        ),
                      ),
                    ],
                  ),
                ),

                /// ✅ النموذج الرئيسي
                Positioned.fill(
                  top: 340,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 50),
                        TextField(
                          controller: controller.emailController,
                          decoration: const InputDecoration(
                            labelText: 'البريد الإلكتروني أو الجامعي',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),

                        TextField(
                          controller: controller.passwordController,
                          obscureText: !controller.showPassword,
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: controller.toggleShowPassword,
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// ✅ تذكرني + نسيت كلمة المرور
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: controller.rememberMe,
                                  onChanged: controller.toggleRememberMe,
                                ),
                                const Text('تذكرني'),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/forgot-password',
                                );
                              },
                              child: const Text('نسيت كلمة المرور؟'),
                            ),
                          ],
                        ),

                        /// ✅ رسالة الخطأ
                        if (controller.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              controller.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        const SizedBox(height: 30),

                        /// ✅ زر تسجيل الدخول
                        SizedBox(
                          width: 370,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: controller.isLoading
                                ? null
                                : () async {
                                    final success = await controller.login();
                                    final isVerified =
                                        AuthService.isEmailVerified();

                                    if (success && isVerified) {
                                      if (controller.rememberMe) {
                                        final prefs =
                                            await SharedPreferences.getInstance();
                                        await prefs.setBool(
                                          'remember_me',
                                          true,
                                        );
                                      }

                                      if (context.mounted) {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/home',
                                        );
                                      }
                                    } else if (success && !isVerified) {
                                      controller.errorMessage =
                                          'يرجى تفعيل بريدك الإلكتروني أولاً.';
                                      controller.notifyListeners();
                                    }
                                  },
                            child: controller.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'تسجيل الدخول',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// ✅ زر إنشاء حساب
                        SizedBox(
                          width: 370,
                          height: 55,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark
                                    ? Colors.white
                                    : const Color.fromARGB(236, 13, 20, 217),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: const Text(
                              'إنشاء حساب جديد',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
