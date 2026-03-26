import 'package:flutter/material.dart';

import '../../../../core/spacing/app_spacing.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../design/staff_management_tokens.dart';

class StaffFeedbackState extends StatelessWidget {
  const StaffFeedbackState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.action,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          decoration: StaffManagementDecorations.outline(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: StaffManagementDecorations.tintedPanel(
                  context,
                  tint: StaffManagementPalette.doctor,
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 30,
                  color: StaffManagementPalette.doctor,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (action != null) ...[
                const SizedBox(height: AppSpacing.lg),
                action!,
              ] else ...[
                const SizedBox(height: AppSpacing.lg),
                const PremiumButton(
                  label: 'Reload module',
                  icon: Icons.refresh_rounded,
                  isSecondary: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
