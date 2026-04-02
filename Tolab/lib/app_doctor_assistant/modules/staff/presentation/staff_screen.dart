import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../app_admin/shared/widgets/status_badge.dart';
import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, SessionUser?>(
      converter: (store) => getCurrentUser(store.state),
      builder: (context, user) {
        if (user == null) return const SizedBox.shrink();
        final profile = DoctorAssistantMockRepository.instance.profileFor(user);

        return DoctorAssistantShell(
          user: user,
          activeRoute: AppRoutes.staff,
          child: DoctorAssistantPageScaffold(
            title: 'Profile',
            subtitle:
                'Profile and workload cards inherit the same section-card language used in admin settings.',
            breadcrumbs: const ['Workspace', 'Profile'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DoctorAssistantPanel(
                  title: user.fullName,
                  subtitle: profile.roleHeadline,
                  trailing: StatusBadge(user.roleType.toUpperCase()),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.roleSummary,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final focus in profile.focusAreas)
                            StatusBadge(focus),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                DoctorAssistantSummaryStrip(metrics: profile.primaryStats),
                const SizedBox(height: AppSpacing.md),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 960;
                    final contact = DoctorAssistantPanel(
                      title: 'Contact',
                      subtitle: 'Current profile and coordination details.',
                      child: Column(
                        children: [
                          DoctorAssistantItemCard(
                            icon: Icons.mail_outline_rounded,
                            title: user.universityEmail,
                            subtitle: 'University email',
                            meta: 'Primary communication channel',
                            statusLabel: 'Active',
                          ),
                          const SizedBox(height: AppSpacing.md),
                          DoctorAssistantItemCard(
                            icon: Icons.phone_outlined,
                            title: profile.phoneLabel,
                            subtitle: profile.locationLabel,
                            meta: 'Office hours: ${profile.officeHours}',
                            statusLabel: 'Scheduled',
                          ),
                        ],
                      ),
                    );

                    final availability = DoctorAssistantPanel(
                      title: 'Availability',
                      subtitle:
                          'Aligned with the compact admin section-card layout.',
                      child: Column(
                        children: [
                          DoctorAssistantItemCard(
                            icon: Icons.schedule_rounded,
                            title: profile.officeHours,
                            subtitle: 'Office hours',
                            meta: 'Weekly student-facing support window',
                            statusLabel: 'Live',
                          ),
                          const SizedBox(height: AppSpacing.md),
                          DoctorAssistantItemCard(
                            icon: Icons.apartment_rounded,
                            title: profile.locationLabel,
                            subtitle: 'Campus location',
                            meta: user.isDoctor
                                ? 'Faculty advising and review room'
                                : 'Tutorial support and assistant operations',
                            statusLabel: 'Scheduled',
                          ),
                        ],
                      ),
                    );

                    if (!isWide) {
                      return Column(
                        children: [
                          contact,
                          const SizedBox(height: AppSpacing.md),
                          availability,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: contact),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: availability),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
