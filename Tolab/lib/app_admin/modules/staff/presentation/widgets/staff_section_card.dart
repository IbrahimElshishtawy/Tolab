import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../design/staff_management_tokens.dart';

class StaffSectionCard extends StatelessWidget {
  const StaffSectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
    this.footer,
    this.accent,
    this.interactive = false,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;
  final Widget? footer;
  final Color? accent;
  final bool interactive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tone = accent ?? StaffManagementPalette.doctor;
    return AppCard(
      interactive: interactive,
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppConstants.cardRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 4,
                      width: 52,
                      decoration: BoxDecoration(
                        color: tone,
                        borderRadius: BorderRadius.circular(
                          AppConstants.pillRadius,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.md),
                Flexible(child: trailing!),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.lg),
            footer!,
          ],
        ],
      ),
    );
  }
}
