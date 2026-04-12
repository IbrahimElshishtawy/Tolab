import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_info_section.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return SafeArea(
      child: AdaptivePageContainer(
        child: profileAsync.when(
          data: (profile) => ListView(
            children: [
              Row(
                children: [
                  AppAvatar(name: profile.fullName, imageUrl: profile.avatarUrl, radius: 28),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.fullName, style: Theme.of(context).textTheme.displaySmall),
                        const SizedBox(height: AppSpacing.xs),
                        Text(profile.email, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  AppButton(
                    label: 'Settings',
                    onPressed: () => context.goNamed(RouteNames.settings),
                    isExpanded: false,
                    variant: AppButtonVariant.secondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              ProfileInfoSection(
                title: 'Personal information',
                items: {
                  'Full name': profile.fullName,
                  'Email': profile.email,
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              ProfileInfoSection(
                title: 'Academic information',
                items: {
                  'Faculty': profile.faculty,
                  'Department': profile.department,
                  'Level': profile.level,
                  'Advisor': profile.academicAdvisor,
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              ProfileInfoSection(
                title: 'Identity information',
                items: {
                  'National ID': maskNationalId(profile.nationalId),
                  'Seat number': profile.seatNumber,
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              ProfileInfoSection(
                title: 'Previous qualification',
                items: {
                  'Qualification': profile.previousQualification,
                  'Current GPA': profile.gpa.toStringAsFixed(2),
                },
              ),
            ],
          ),
          loading: () => const LoadingWidget(label: 'Loading profile...'),
          error: (error, stackTrace) => ErrorStateWidget(message: error.toString()),
        ),
      ),
    );
  }
}
