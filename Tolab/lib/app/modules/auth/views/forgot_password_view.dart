import 'package:flutter/material.dart';

import '../../../core/values/app_spacing.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/premium_app_bar.dart';
import '../../../core/widgets/glass_panel.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      appBar: PremiumAppBar(title: 'Password help'),
      body: _ForgotPasswordBody(),
    );
  }
}

class _ForgotPasswordBody extends StatelessWidget {
  const _ForgotPasswordBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password reset is managed by your university system.',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'If self-service reset is not enabled by the backend yet, contact your department admin or LMS support to restore access.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
