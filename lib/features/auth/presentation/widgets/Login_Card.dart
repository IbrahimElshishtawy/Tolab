// ignore_for_file: deprecated_member_use, file_names

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tolab_fci/features/auth/presentation/widgets/Email_Field.dart';
import 'package:tolab_fci/features/auth/presentation/widgets/Password_Field.dart';
import 'package:tolab_fci/features/auth/presentation/widgets/Login_Header.dart';
import 'package:tolab_fci/features/auth/presentation/widgets/Role_Selector.dart';
import 'package:tolab_fci/features/auth/ReduX/action/auth_actions.dart';
import 'package:tolab_fci/redux/state/app_state.dart';

class LoginCard extends StatefulWidget {
  final String selectedRole;
  final TextEditingController emailController;
  final ValueChanged<String> onRoleChanged;
  final bool isLoading;

  const LoginCard({
    super.key,
    required this.selectedRole,
    required this.emailController,
    required this.onRoleChanged,
    required this.isLoading,
  });

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final TextEditingController passwordController = TextEditingController();

  bool _isValidEmail(String email) {
    return email.isNotEmpty && email.contains('@');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = widget.emailController.text.trim();
    final isEmailValid = _isValidEmail(email);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LoginHeader(),
            const SizedBox(height: 30),

            /// اختيار الدور
            RoleSelector(selectedRole: widget.selectedRole, onChanged: widget.onRoleChanged),

            const SizedBox(height: 20),

            /// إدخال الإيميل
            EmailField(controller: widget.emailController),

            const SizedBox(height: 20),

            /// إدخال كلمة المرور
            PasswordField(controller: passwordController),

            const SizedBox(height: 30),

            /// زر الدخول
            ElevatedButton(
              onPressed: widget.isLoading || !isEmailValid
                  ? null
                  : () {
                      StoreProvider.of<AppState>(context).dispatch(
                        LoginAction(
                          email: email,
                          password: passwordController.text,
                          role: widget.selectedRole,
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: widget.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'تسجيل الدخول',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
