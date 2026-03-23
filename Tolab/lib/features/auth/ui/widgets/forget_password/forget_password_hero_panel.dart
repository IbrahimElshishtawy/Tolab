import 'package:flutter/material.dart';

import '../auth_hero_panel.dart';

class ForgetPasswordHeroPanel extends StatelessWidget {
  final bool compact;

  const ForgetPasswordHeroPanel({
    super.key,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return AuthHeroPanel(
      compact: compact,
      badgeIcon: Icons.lock_reset_rounded,
      badgeLabel: 'Password recovery',
      title: 'Recover access securely',
      subtitle:
          'Enter your university email and we will send a verification code to continue resetting your password.',
      features: const [
        AuthHeroFeature(
          icon: Icons.mark_email_read_rounded,
          label: 'Email verification',
        ),
        AuthHeroFeature(icon: Icons.shield_rounded, label: 'Secure recovery'),
        AuthHeroFeature(icon: Icons.bolt_rounded, label: 'Fast access'),
      ],
    );
  }
}
