import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_safe_image.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.radius = 22,
    this.imageUrl,
    this.isMale = true,
  });

  final String name;
  final double radius;
  final String? imageUrl;
  final bool isMale;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final initials = name
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join()
        .toUpperCase();

    final size = radius * 2;
    final defaultAssetPath = isMale
        ? 'assets/images/avatar_placeholder_male.svg'
        : 'assets/images/avatar_placeholder_female.svg';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isMale ? palette.primarySoft : Colors.pink.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AppSafeImage(
            imageUrl: imageUrl,
            assetPath: defaultAssetPath,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
          if (!AppSafeImage.isValidRemoteUrl(imageUrl))
            Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              color: Colors.transparent,
              child: Text(
                initials,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isMale ? Theme.of(context).colorScheme.primary : Colors.pink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
