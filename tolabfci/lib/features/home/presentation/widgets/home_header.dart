import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/home_dashboard.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/notification_badge.dart';
import '../../../../core/router/route_names.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.dashboard,
    required this.unreadCount,
  });

  final HomeDashboardData dashboard;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppAvatar(name: dashboard.profile.fullName, imageUrl: dashboard.profile.avatarUrl),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello, ${dashboard.profile.fullName.split(' ').first}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${dashboard.profile.department} • ${dashboard.profile.level}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        AppBadge(label: 'GPA ${dashboard.profile.gpa.toStringAsFixed(2)}'),
        const SizedBox(width: AppSpacing.sm),
        IconButton(
          onPressed: () => context.goNamed(RouteNames.notifications),
          icon: NotificationBadge(
            count: unreadCount,
            child: const Icon(Icons.notifications_none_rounded),
          ),
        ),
      ],
    );
  }
}

