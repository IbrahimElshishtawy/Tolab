import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';

class AppSafeImage extends StatelessWidget {
  const AppSafeImage({
    super.key,
    this.imageUrl,
    this.assetPath = 'assets/images/avatar_placeholder.svg',
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.backgroundColor,
    this.errorIcon = Icons.broken_image_outlined,
  });

  final String? imageUrl;
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final IconData errorIcon;

  static bool isValidRemoteUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return false;
    }

    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return false;
    }

    return uri.scheme == 'http' || uri.scheme == 'https';
  }

  @override
  Widget build(BuildContext context) {
    final child = isValidRemoteUrl(imageUrl)
        ? Image.network(
            imageUrl!.trim(),
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return _AssetFallback(
                assetPath: assetPath,
                width: width,
                height: height,
                fit: fit,
                icon: errorIcon,
              );
            },
          )
        : _AssetFallback(
            assetPath: assetPath,
            width: width,
            height: height,
            fit: fit,
          );

    if (borderRadius == null) {
      return child;
    }

    return ClipRRect(
      borderRadius: borderRadius!,
      child: ColoredBox(
        color: backgroundColor ?? AppColors.primarySoft,
        child: child,
      ),
    );
  }
}

class _AssetFallback extends StatelessWidget {
  const _AssetFallback({
    required this.assetPath,
    required this.width,
    required this.height,
    required this.fit,
    this.icon,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SvgPicture.asset(
          assetPath,
          width: width,
          height: height,
          fit: fit,
        ),
        if (icon != null)
          Container(
            width: (width ?? 80) * 0.28,
            height: (height ?? 80) * 0.28,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: (width ?? 80) * 0.14,
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }
}
