// ignore_for_file: deprecated_member_use

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6D7B90),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF17212F),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                role,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF3469C8),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFBFD5FF), Color(0xFFE9F1FF)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl!)
                  : null,
              child: profileImageUrl == null
                  ? const Icon(Icons.person, color: Color(0xFF3469C8))
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
