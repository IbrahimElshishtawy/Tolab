import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/student_profile.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/notification_badge.dart';

class StudentHomeHeader extends StatelessWidget {
  const StudentHomeHeader({
    super.key,
    required this.profile,
    required this.unreadCount,
  });

  final StudentProfile profile;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final firstName = profile.fullName.split(' ').first;

    return AppCard(
      backgroundColor: AppColors.surfaceAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAvatar(
                name: profile.fullName,
                radius: 26,
                imageUrl: profile.avatarUrl.isEmpty ? null : profile.avatarUrl,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, $firstName',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${profile.department} • ${profile.level}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => context.goNamed(RouteNames.notifications),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textPrimary,
                ),
                icon: NotificationBadge(
                  count: unreadCount,
                  child: const Icon(Icons.notifications_none_rounded),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppBadge(label: 'GPA ${profile.gpa.toStringAsFixed(2)}'),
              AppBadge(label: profile.faculty, backgroundColor: Colors.white),
              AppBadge(
                label: 'Advisor ${profile.academicAdvisor}',
                backgroundColor: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
