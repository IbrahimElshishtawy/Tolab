import 'package:flutter/material.dart';

import '../../../../core/spacing/app_spacing.dart';
import '../../models/subject_management_models.dart';
import '../design/subjects_management_tokens.dart';
import 'subject_primitives.dart';

class SubjectPermissionsPanel extends StatelessWidget {
  const SubjectPermissionsPanel({super.key, required this.subject});

  final SubjectRecord subject;

  @override
  Widget build(BuildContext context) {
    return SubjectSectionFrame(
      title: 'Permissions and privacy',
      subtitle:
          'Clear control over posts, group moderation, summaries, access behavior, and staff-only student visibility.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: SubjectsManagementDecorations.tintedPanel(
              context,
              tint: SubjectsManagementPalette.violet,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.privacy_tip_outlined,
                    color: SubjectsManagementPalette.violet,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Student lists are visible to admin, doctor, and assistant only. Students cannot see each other accounts or peer identity inside this module.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final category in subject.permissions) ...[
            _PermissionCategoryCard(category: category),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _PermissionCategoryCard extends StatelessWidget {
  const _PermissionCategoryCard({required this.category});

  final SubjectPermissionCategory category;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SubjectsManagementPalette.muted(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SubjectsManagementPalette.border(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: SubjectsManagementDecorations.tintedPanel(
                    context,
                    tint: SubjectsManagementPalette.accent,
                  ),
                  child: Icon(
                    category.icon,
                    color: SubjectsManagementPalette.accent,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            for (final permission in category.permissions) ...[
              _PermissionTile(permission: permission),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({required this.permission});

  final SubjectPermissionRule permission;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SubjectsManagementPalette.border(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    permission.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    permission.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Switch(value: permission.enabled, onChanged: (_) {}),
          ],
        ),
      ),
    );
  }
}
