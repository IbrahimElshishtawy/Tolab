// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tolab_fci/features/auth/presentation/widgets/Email_Field.dart';
import 'package:tolab_fci/features/auth/presentation/widgets/Login_Header.dart';
import 'package:tolab_fci/features/auth/presentation/widgets/Microsoft_Button.dart';
import 'package:tolab_fci/features/auth/presentation/widgets/Role_Selector.dart';
import 'package:tolab_fci/redux/actions/auth_actions.dart';
import 'package:tolab_fci/redux/state/app_state.dart';

class LoginCard extends StatelessWidget {
  final String selectedRole;
  final TextEditingController emailController;
  final ValueChanged<String> onRoleChanged;

  const LoginCard({
    super.key,
    required this.selectedRole,
    required this.emailController,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF121212)
            : Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, -6),
                ),
              ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LoginHeader(),
            const SizedBox(height: 30),
            RoleSelector(selectedRole: selectedRole, onChanged: onRoleChanged),
            const SizedBox(height: 30),
            EmailField(controller: emailController),
            const SizedBox(height: 30),
            MicrosoftButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                debugPrint('LOGIN CLICKED: ${emailController.text}');

                StoreProvider.of<AppState>(context).dispatch(
                  LoginRequestAction(
                    selectedRole: selectedRole,
                    emailHint: emailController.text.trim(),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
