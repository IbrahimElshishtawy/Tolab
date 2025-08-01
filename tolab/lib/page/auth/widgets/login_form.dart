// lib/Features/auth/widgets/login_form.dart
// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tolab/page/auth/controllers/src/google_sign_in_service.dart';
import 'package:tolab/page/auth/controllers/login_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool isPasswordVisible = false;
  User? _user;

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

  Future<void> _handleGoogleSignIn() async {
    try {
      final userCredential = await GoogleSignInService.signInWithGoogle();
      if (userCredential == null) return;

      final user = userCredential.user;
      if (user != null) {
        setState(() {
          _user = user;
        });

        // ✅ إنشاء شات مع نفسه إذا ماكانش موجود
        await createSelfChatIfNotExists(user.uid);

        if (kDebugMode) print('مرحبًا ${user.displayName}');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email', user.email ?? '');
        await prefs.setBool('remember_me', true);

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/choose-role');
      }
    } catch (e) {
      if (kDebugMode) print('فشل تسجيل الدخول: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تسجيل الدخول بواسطة Google')),
        );
      }
    }
  }

  Future<void> createSelfChatIfNotExists(String userId) async {
    final chatRef = FirebaseFirestore.instance
        .collection('chats')
        .where('members', isEqualTo: [userId]);

    final snapshot = await chatRef.get();

    if (snapshot.docs.isEmpty) {
      await FirebaseFirestore.instance.collection('chats').add({
        'members': [userId],
        'createdAt': FieldValue.serverTimestamp(),
        'isSelfChat': true,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<LoginController>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // عرض بيانات المستخدم بعد تسجيل جوجل
        if (_user != null) ...[
          CircleAvatar(
            radius: 40,
            backgroundImage: _user!.photoURL != null
                ? NetworkImage(_user!.photoURL!)
                : null,
            child: _user!.photoURL == null
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            _user!.displayName ?? _user!.email ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
        ],

        // حقل البريد الإلكتروني
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

        // حقل كلمة المرور
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
        const SizedBox(height: 10),

        //  و رابط نسيان كلمة المرور
        Row(
          children: [
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
        const SizedBox(height: 12),

        // زر تسجيل بالبريد وكلمة المرور
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
                        : const Color(0xFF0E1CE2),
                  ),
                  child: const Text('Login', style: TextStyle(fontSize: 20)),
                ),
        ),
        const SizedBox(height: 16),

        // زر تسجيل الدخول بجوجل
        ElevatedButton.icon(
          icon: Image.asset('assets/image_App/google_logo.png', height: 22),
          label: const Text("Sign in with Google"),
          onPressed: _handleGoogleSignIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ),
      ],
    );
  }
}
