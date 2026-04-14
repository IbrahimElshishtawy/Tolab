import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({
    super.key,
    required this.count,
    required this.child,
  });

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -2,
          top: -2,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: AppColors.badge,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              count > 9 ? '9+' : '$count',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
