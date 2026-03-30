import 'package:flutter/material.dart';

import '../../../../core/animations/app_motion.dart';
import '../../../../core/colors/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../models/moderation_models.dart';

Future<void> showModerationPreviewDialog({
  required BuildContext context,
  required String title,
  required String subtitle,
  required String status,
  required String content,
  required List<MapEntry<String, String>> metadata,
  required List<Widget> actions,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Moderation preview',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: AppMotion.medium,
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              subtitle,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      StatusBadge(status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: metadata
                        .map(
                          (entry) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(
                                AppConstants.smallRadius,
                              ),
                            ),
                            child: Text(
                              '${entry.key}: ${entry.value}',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(
                        AppConstants.mediumRadius,
                      ),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Text(content),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                      const Spacer(),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: actions,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.entrance,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

Future<List<String>?> showAssignModeratorsDialog({
  required BuildContext context,
  required String groupName,
  required List<ModerationModeratorAccount> moderators,
  required List<String> selectedIds,
}) {
  final selected = {...selectedIds};
  return showDialog<List<String>>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Assign moderators to $groupName'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: moderators
                    .map(
                      (moderator) => CheckboxListTile(
                        value: selected.contains(moderator.id),
                        onChanged: (value) {
                          setState(() {
                            if (value ?? false) {
                              selected.add(moderator.id);
                            } else {
                              selected.remove(moderator.id);
                            }
                          });
                        },
                        title: Text(moderator.name),
                        subtitle: Text(
                          '${moderator.role}  •  ${moderator.speciality}',
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              PremiumButton(
                label: 'Save',
                icon: Icons.check_rounded,
                onPressed: () => Navigator.of(
                  context,
                ).pop(selected.toList(growable: false)),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget buildPreviewActionButton({
  required String label,
  required IconData icon,
  required VoidCallback onPressed,
  bool destructive = false,
}) {
  return PremiumButton(
    label: label,
    icon: icon,
    isDestructive: destructive,
    isSecondary: !destructive,
    onPressed: onPressed,
  );
}

class ModerationNoticeBanner extends StatelessWidget {
  const ModerationNoticeBanner({
    super.key,
    required this.message,
    required this.isFallback,
  });

  final String message;
  final bool isFallback;

  @override
  Widget build(BuildContext context) {
    final color = isFallback ? AppColors.warning : AppColors.info;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      backgroundColor: color.withValues(alpha: 0.08),
      borderColor: color.withValues(alpha: 0.18),
      showShadow: false,
      child: Row(
        children: [
          Icon(
            isFallback ? Icons.cloud_off_outlined : Icons.check_circle_outline,
            color: color,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
