import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.radius = 22,
    this.imageUrl,
  });

  final String name;
  final double radius;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join()
        .toUpperCase();

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primarySoft,
      foregroundColor: AppColors.primary,
      backgroundImage: imageUrl == null ? null : NetworkImage(imageUrl!),
      child: imageUrl == null ? Text(initials) : null,
    );
  }
}
