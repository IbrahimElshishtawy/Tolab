// ignore_for_file: dead_code

import 'package:eduhub/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController(text: 'admin@center.com');
  final _passwordController = TextEditingController(text: '123456');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            final role = state.user.role;
            if (role == 'admin') {
              context.goNamed(RouteNames.adminDashboard);
            } else if (role == 'teacher') {
              context.goNamed(RouteNames.teacherHome);
            } else if (role == 'student') {
              context.goNamed(RouteNames.studentHome);
            } else if (role == 'parent') {
              context.goNamed(RouteNames.parentDashboard);
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          context.read<AuthBloc>().add(
                            LoginRequested(
                              _emailController.text.trim(),
                              _passwordController.text.trim(),
                            ),
                          );
                        },
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Login'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'جرب:\n'
                  'admin@center.com / 123456 (مدير)\n'
                  'teacher@center.com / 123456 (مدرس)\n'
                  'student@center.com / 123456 (طالب)\n'
                  'parent@center.com / 123456 (ولي أمر)',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
