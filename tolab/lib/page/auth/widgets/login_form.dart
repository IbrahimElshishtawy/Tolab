import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tolab/page/auth/controllers/login_cubit.dart';
import 'package:tolab/page/auth/controllers/login_state.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<LoginCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (state is LoginFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is LoginGoogleSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تسجيل الدخول بواسطة Google')),
          );
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (cubit.user != null) ...[
              CircleAvatar(
                radius: 40,
                backgroundImage: cubit.user!.photoURL != null
                    ? NetworkImage(cubit.user!.photoURL!)
                    : null,
                child: cubit.user!.photoURL == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                cubit.user!.displayName ?? cubit.user!.email ?? '',
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
              obscureText: !cubit.isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    cubit.isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () => cubit.togglePasswordVisibility(),
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
              onPressed: () => cubit.handleGoogleSignIn(context),
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
