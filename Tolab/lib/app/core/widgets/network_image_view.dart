import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NetworkImageView extends StatelessWidget {
  const NetworkImageView({
    super.key,
    required this.imageUrl,
    this.height = 80,
    this.width = double.infinity,
    this.radius = 20,
    this.icon = Icons.image_outlined,
  });

  final String? imageUrl;
  final double height;
  final double width;
  final double radius;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (imageUrl?.isEmpty != false) {
      return _Placeholder(
        height: height,
        width: width,
        radius: radius,
        icon: icon,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        height: height,
        width: width,
        fit: BoxFit.cover,
        placeholder: (context, url) => _Placeholder(
          height: height,
          width: width,
          radius: radius,
          icon: icon,
        ),
        errorWidget: (context, url, error) => _Placeholder(
          height: height,
          width: width,
          radius: radius,
          icon: icon,
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.height,
    required this.width,
    required this.radius,
    required this.icon,
  });

  final double height;
  final double width;
  final double radius;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Icon(icon, color: Theme.of(context).colorScheme.primary),
    );
  }
}
