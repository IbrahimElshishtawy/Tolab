// ignore_for_file: deprecated_member_use, file_names

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
  final bool isLoading;

  const LoginCard({
    super.key,
    required this.selectedRole,
    required this.emailController,
    required this.onRoleChanged,
    required this.isLoading,
  });

  bool _isValidEmail(String email) {
    return email.isNotEmpty &&
        email.contains('@') &&
        email.endsWith('tanta.edu.eg');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final email = emailController.text.trim().toLowerCase();
    final isEmailValid = _isValidEmail(email);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF121212)
            : Theme.of(context).colorScheme.surface,
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
            RoleSelector(selectedRole: selectedRole, onChanged: onRoleChanged),

            const SizedBox(height: 30),

            /// إدخال الإيميل
            EmailField(controller: emailController),

            const SizedBox(height: 30),

            /// زر Microsoft
            StoreConnector<AppState, bool>(
              distinct: true,
              converter: (store) => store.state.authState.isLoading,
              builder: (context, isLoading) {
                return MicrosoftButton(
                  isLoading: isLoading,
                  isEnabled: isEmailValid,
                  onPressed: () {
                    StoreProvider.of<AppState>(context).dispatch(
                      CheckEmailBeforeMicrosoftLoginAction(
                        email: email,
                        selectedRole: selectedRole,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
