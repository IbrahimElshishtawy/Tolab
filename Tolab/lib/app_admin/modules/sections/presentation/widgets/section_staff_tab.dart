import 'package:flutter/material.dart';

import '../../../../../app/localization/app_localizations.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../models/section_management_models.dart';
import 'section_management_primitives.dart';

class SectionStaffTab extends StatelessWidget {
  const SectionStaffTab({
    super.key,
    required this.staff,
    required this.onAssignStaff,
    required this.onAssignMember,
    required this.onUnassignMember,
  });

  final List<SectionStaffRecord> staff;
  final VoidCallback onAssignStaff;
  final void Function(SectionStaffRecord member) onAssignMember;
  final void Function(SectionStaffRecord member) onUnassignMember;

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppBreakpoints.isDesktop(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SectionPanelHeader(
            title: context.l10n.byValue('Assigned staff'),
            subtitle:
                context.l10n.byValue('Manage doctors and assistants with role visibility, load balancing, and assignment controls.'),
            trailing: PremiumButton(
              label: 'Assign staff',
              icon: Icons.person_add_alt_rounded,
              onPressed: onAssignStaff,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: staff.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 2 : 1,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: isDesktop ? 2.1 : 1.45,
          ),
          itemBuilder: (context, index) {
            final member = staff[index];
            return AppCard(
              interactive: true,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SectionAvatar(
                        label: member.initials,
                        backgroundColor: member.role == 'Doctor'
                            ? AppColors.primary
                            : AppColors.info,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.byValue(member.name),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.l10n.byValue(member.focusArea),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(member.role),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(child: StatusBadge(member.status)),
                      Text(
                        context.l10n.byValue(member.officeHoursLabel),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SectionCapacityBar(
                    value: member.loadRate,
                    label: '${context.l10n.byValue('Teaching load')} ${(member.loadRate * 100).round()}%',
                  ),
                  const Spacer(),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      PremiumButton(
                        label: 'Assign',
                        icon: Icons.add_link_rounded,
                        isSecondary: true,
                        onPressed: () => onAssignMember(member),
                      ),
                      PremiumButton(
                        label: 'Unassign',
                        icon: Icons.link_off_rounded,
                        isSecondary: true,
                        onPressed: () => onUnassignMember(member),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
