import 'package:flutter/material.dart';

import '../../../../core/widgets/app_button.dart';

class LoginSubmitButton extends StatelessWidget {
  const LoginSubmitButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: isLoading ? 'Signing in...' : 'Sign in',
      onPressed: isLoading ? null : onPressed,
    );
  }
}
