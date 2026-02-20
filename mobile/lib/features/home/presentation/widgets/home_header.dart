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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                userName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                role,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 25,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            backgroundImage:
                profileImageUrl != null ? NetworkImage(profileImageUrl!) : null,
            child: profileImageUrl == null
                ? Icon(Icons.person, color: theme.colorScheme.primary)
                : null,
          ),
        ],
      ),
    );
  }
}
