import 'package:flutter/material.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/theme/app_spacing.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('بوابة الطالب', 'Student portal'),
          style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          context.tr('مرحبًا بعودتك', 'Welcome back'),
          style: textTheme.displaySmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          context.tr(
            'سجّل دخولك بالبريد الجامعي لمتابعة موادك وكويزاتك وجدولك.',
            'Sign in with your university email to continue.',
          ),
          style: textTheme.bodySmall?.copyWith(height: 1.45),
        ),
      ],
    );
  }
}
