import 'package:flutter/material.dart';

import '../auth_hero_panel.dart';

class LoginHeroPanel extends StatelessWidget {
  final bool compact;

  const LoginHeroPanel({
    super.key,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return AuthHeroPanel(
      compact: compact,
      badgeIcon: Icons.verified_user_rounded,
      badgeLabel: 'University access portal',
      title: 'Welcome back',
      subtitle:
          'Sign in to manage courses, track academic activity, and access your university workspace from one secure place.',
      features: const [
        AuthHeroFeature(
          icon: Icons.auto_awesome_mosaic_rounded,
          label: 'Modern dashboard',
        ),
        AuthHeroFeature(icon: Icons.shield_rounded, label: 'Secure access'),
        AuthHeroFeature(
          icon: Icons.groups_2_rounded,
          label: 'Faculty workflow',
        ),
      ],
    );
  }
}
