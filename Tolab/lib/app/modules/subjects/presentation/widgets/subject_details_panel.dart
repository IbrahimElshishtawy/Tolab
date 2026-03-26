import 'package:flutter/material.dart';

import '../../../../core/spacing/app_spacing.dart';
import '../../models/subject_management_models.dart';
import '../design/subjects_management_tokens.dart';
import 'subject_feedback_state.dart';
import 'subject_permissions_panel.dart';
import 'subject_primitives.dart';

class SubjectDetailsPanel extends StatelessWidget {
  const SubjectDetailsPanel({super.key, required this.subject, this.onEdit});

  final SubjectRecord? subject;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    if (subject == null) {
      return const SubjectFeedbackState(
        title: 'Select a subject',
        message:
            'Open any subject from the table or grouped view to inspect enrollment, privacy, group activity, summaries, and access controls.',
      );
    }

    final item = subject!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SubjectSectionFrame(
            title: item.name,
            subtitle: '${item.code}  •  ${item.updatedAtLabel}',
            trailing: onEdit == null
                ? null
                : FilledButton.icon(
                    onPressed: onEdit,
                    style: SubjectsManagementButtons.subtle(context),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                  ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    SubjectToneBadge(item.status),
                    SubjectToneBadge(item.department),
                    SubjectToneBadge(item.academicYear),
                    SubjectToneBadge('Code + Link Access'),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    SubjectInfoPill(
                      label: 'Credit hours',
                      value: '${item.creditHours}',
                      tint: SubjectsManagementPalette.accent,
                    ),
                    SubjectInfoPill(
                      label: 'Subject hours',
                      value: '${item.contactHours}',
                      tint: SubjectsManagementPalette.teal,
                    ),
                    SubjectInfoPill(
                      label: 'Eligible / enrolled',
                      value:
                          '${item.eligibleStudents}/${item.enrolledStudents}',
                      tint: SubjectsManagementPalette.coral,
                    ),
                    SubjectInfoPill(
                      label: 'Activity',
                      value: '${item.postsAndSummaries}',
                      tint: SubjectsManagementPalette.violet,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SubjectSectionFrame(
            title: 'Enrollment and students',
            subtitle:
                'Only admin, doctor, and assistant can see these students. Students cannot see each other.',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SubjectInfoPill(
                        label: 'Eligible students',
                        value: '${item.eligibleStudents}',
                        tint: SubjectsManagementPalette.accent,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: SubjectInfoPill(
                        label: 'Enrolled students',
                        value: '${item.enrolledStudents}',
                        tint: SubjectsManagementPalette.teal,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: SubjectInfoPill(
                        label: 'Late joins',
                        value:
                            '${item.students.where((student) => student.lateJoin).length}',
                        tint: SubjectsManagementPalette.gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                for (final student in item.students) ...[
                  _StudentTile(student: student),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SubjectSectionFrame(
            title: 'Group and community',
            subtitle:
                'Visual group status, moderation scope, and member coverage.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    SubjectToneBadge(
                      item.group.enabled ? 'Community live' : 'Community off',
                    ),
                    SubjectToneBadge(item.group.moderationLabel),
                    SubjectToneBadge(item.group.engagementLabel),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: SubjectInfoPill(
                        label: 'Group',
                        value: item.group.name,
                        tint: SubjectsManagementPalette.violet,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: SubjectInfoPill(
                        label: 'Members',
                        value: '${item.group.members}',
                        tint: SubjectsManagementPalette.teal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SubjectSectionFrame(
            title: 'Posts and summaries',
            subtitle:
                'Control who opens posts, who monitors them, and how summary packs are distributed.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    SubjectInfoPill(
                      label: 'Posts',
                      value: '${item.posts.count}',
                      tint: SubjectsManagementPalette.accent,
                    ),
                    SubjectInfoPill(
                      label: 'Summaries',
                      value: '${item.summaries.count}',
                      tint: SubjectsManagementPalette.coral,
                    ),
                    SubjectInfoPill(
                      label: 'Opening',
                      value: item.posts.openingScope,
                      tint: SubjectsManagementPalette.gold,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                for (final post in item.posts.recent) ...[
                  _TimelineListTile(
                    title: post.title,
                    subtitle: '${post.author}  •  ${post.timeLabel}',
                    badge: post.status,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                const SizedBox(height: AppSpacing.sm),
                for (final summary in item.summaries.latest) ...[
                  _TimelineListTile(
                    title: summary.title,
                    subtitle:
                        '${summary.versionLabel}  •  ${summary.updatedAtLabel}',
                    badge: 'Summary',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SubjectSectionFrame(
            title: 'Access control',
            subtitle:
                'Create or regenerate secure code/link access and support late registration entry clearly.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _AccessCard(
                        label: 'Access code',
                        value: item.access.code,
                        tint: SubjectsManagementPalette.accent,
                        icon: Icons.password_rounded,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _AccessCard(
                        label: 'Access link',
                        value: item.access.link,
                        tint: SubjectsManagementPalette.violet,
                        icon: Icons.link_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  item.access.lateJoinLabel,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  item.access.regeneratedAtLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    FilledButton.icon(
                      onPressed: () {},
                      style: SubjectsManagementButtons.subtle(
                        context,
                        tint: SubjectsManagementPalette.accent,
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Regenerate code'),
                    ),
                    FilledButton.icon(
                      onPressed: () {},
                      style: SubjectsManagementButtons.subtle(
                        context,
                        tint: SubjectsManagementPalette.violet,
                      ),
                      icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                      label: const Text('Regenerate link'),
                    ),
                    FilledButton.icon(
                      onPressed: () {},
                      style: SubjectsManagementButtons.subtle(
                        context,
                        tint: SubjectsManagementPalette.teal,
                      ),
                      icon: const Icon(Icons.content_copy_rounded, size: 18),
                      label: const Text('Copy / share'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SubjectSectionFrame(
            title: 'Staff visibility',
            subtitle:
                'Doctor and assistant are surfaced clearly with linked account and channel-style visibility.',
            child: Column(
              children: [
                _StaffAccountCard(staff: item.doctor),
                const SizedBox(height: AppSpacing.sm),
                _StaffAccountCard(staff: item.assistant),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SubjectSectionFrame(
            title: 'Monitoring and activity',
            subtitle:
                'Recent actions, engagement indicators, and late student join monitoring.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final event in item.timeline) ...[
                  _TimelineListTile(
                    title: event.title,
                    subtitle: '${event.subtitle}  •  ${event.timeLabel}',
                    badge: event.tone,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SubjectPermissionsPanel(subject: item),
        ],
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  const _StudentTile({required this.student});

  final SubjectStudentItem student;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SubjectsManagementPalette.muted(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SubjectsManagementPalette.border(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: SubjectsManagementPalette.accent.withValues(
                alpha: 0.12,
              ),
              foregroundColor: SubjectsManagementPalette.accent,
              child: Text(student.name.characters.first),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${student.id}  •  ${student.section}  •  ${student.level}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SubjectToneBadge(student.status),
                const SizedBox(height: 6),
                Text(
                  student.privacyLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessCard extends StatelessWidget {
  const _AccessCard({
    required this.label,
    required this.value,
    required this.tint,
    required this.icon,
  });

  final String label;
  final String value;
  final Color tint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: SubjectsManagementDecorations.tintedPanel(
        context,
        tint: tint,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: tint),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 4),
                  Text(value, style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffAccountCard extends StatelessWidget {
  const _StaffAccountCard({required this.staff});

  final SubjectStaffMember staff;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SubjectsManagementPalette.muted(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: SubjectsManagementPalette.border(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: staff.color.withValues(alpha: 0.14),
              foregroundColor: staff.color,
              child: Text(staff.name.characters.first),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${staff.role}  •  ${staff.email}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    staff.channelLabel,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            SubjectToneBadge(staff.status),
          ],
        ),
      ),
    );
  }
}

class _TimelineListTile extends StatelessWidget {
  const _TimelineListTile({
    required this.title,
    required this.subtitle,
    required this.badge,
  });

  final String title;
  final String subtitle;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SubjectsManagementPalette.border(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            SubjectToneBadge(badge),
          ],
        ),
      ),
    );
  }
}
