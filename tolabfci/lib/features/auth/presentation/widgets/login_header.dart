import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome back', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Sign in with your university email to continue to your courses, quizzes, and subject groups.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
