// lib/Features/auth/widgets/login_form.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tolab/page/auth/controllers/login_cubit.dart';
import 'package:tolab/page/auth/controllers/login_state.dart';
import 'package:tolab/page/auth/controllers/src/google_sign_in_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    context.read<LoginCubit>().loadSavedCredentials();
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

        await createSelfChatIfNotExists(user.uid);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email', user.email ?? '');
        await prefs.setBool('remember_me', true);

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/choose-role');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل تسجيل الدخول بواسطة Google')),
      );
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
    final cubit = context.read<LoginCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) async {
        if (state is LoginSuccess) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (state is LoginFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
            ],

            TextFormField(
              controller: cubit.emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: cubit.passwordController,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => isPasswordVisible = !isPasswordVisible);
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Checkbox(
                  value: cubit.rememberMe,
                  onChanged: (value) {
                    cubit.toggleRememberMe(value ?? false);
                  },
                ),
                const Text("Remember me"),
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/forgot-password'),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 50,
              child: state is LoginLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () => cubit.login(context),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: isDark
                            ? const Color(0xFF1E88E5)
                            : const Color(0xFF0E1CE2),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
            ),
            const SizedBox(height: 16),

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
      },
    );
  }
}
