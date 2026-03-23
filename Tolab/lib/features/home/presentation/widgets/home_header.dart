import 'dart:ui';

import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String role;
  final String? profileImageUrl;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.role,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF718198),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  userName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF17212F),
                        letterSpacing: -0.4,
                      ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.68),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE3EAF4)),
                      ),
                      child: Text(
                        role,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: const Color(0xFF3469C8),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _HeaderIconButton(
            icon: Icons.notifications_none_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 10),
          _ProfileAvatar(profileImageUrl: profileImageUrl),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: Colors.white.withValues(alpha: 0.70),
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2EAF4)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: Color(0xFF325B9B),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? profileImageUrl;

  const _ProfileAvatar({
    required this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFBFD5FF), Color(0xFFE9F1FF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F2C49),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.white,
        backgroundImage:
            profileImageUrl != null ? NetworkImage(profileImageUrl!) : null,
        child: profileImageUrl == null
            ? const Icon(Icons.person, color: Color(0xFF3469C8))
            : null,
      ),
    );
  }
}
