import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../app_admin/core/colors/app_colors.dart';
import '../../../../../app_admin/core/constants/app_constants.dart';
import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../../app_admin/core/widgets/app_card.dart';
import '../../../../../app_admin/shared/widgets/premium_button.dart';
import '../../../../../app_admin/shared/widgets/status_badge.dart';
import '../../models/course_workspace_models.dart';
import '../course_workspace_localizations.dart';

class WorkspaceSectionCard extends StatelessWidget {
  const WorkspaceSectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.md),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class WorkspaceStatCard extends StatelessWidget {
  const WorkspaceStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.caption,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String caption;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(caption, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class WorkspaceTabStrip extends StatelessWidget {
  const WorkspaceTabStrip({
    super.key,
    required this.copy,
    required this.selectedTab,
    required this.onChanged,
  });

  final CourseWorkspaceCopy copy;
  final CourseWorkspaceTab selectedTab;
  final ValueChanged<CourseWorkspaceTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: CourseWorkspaceTab.values.map((tab) {
        final isSelected = tab == selectedTab;
        return ChoiceChip(
          label: Text(_labelFor(copy, tab)),
          selected: isSelected,
          onSelected: (_) => onChanged(tab),
          selectedColor: AppColors.primary.withValues(alpha: .16),
          side: BorderSide(
            color: isSelected ? AppColors.primary : Theme.of(context).dividerColor,
          ),
        );
      }).toList(),
    );
  }

  String _labelFor(CourseWorkspaceCopy copy, CourseWorkspaceTab tab) {
    return switch (tab) {
      CourseWorkspaceTab.overview => copy.text('Overview', 'نظرة عامة'),
      CourseWorkspaceTab.quizBuilder => copy.text('Quiz Builder', 'منشئ الكويز'),
      CourseWorkspaceTab.announcements => copy.text('Announcements', 'الإعلانات'),
      CourseWorkspaceTab.group => copy.text('Group', 'الجروب'),
      CourseWorkspaceTab.sessions => copy.text('Lectures & Sections', 'المحاضرات والسكاشن'),
      CourseWorkspaceTab.schedule => copy.text('Schedule', 'الجدول'),
      CourseWorkspaceTab.students => copy.text('Students', 'الطلبة'),
      CourseWorkspaceTab.analytics => copy.text('Analytics', 'التحليلات'),
    };
  }
}

class WorkspaceLanguageSwitch extends StatelessWidget {
  const WorkspaceLanguageSwitch({
    super.key,
    required this.language,
    required this.onChanged,
  });

  final CourseWorkspaceLanguage language;
  final ValueChanged<CourseWorkspaceLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      children: [
        ChoiceChip(
          label: const Text('English'),
          selected: language == CourseWorkspaceLanguage.english,
          onSelected: (_) => onChanged(CourseWorkspaceLanguage.english),
        ),
        ChoiceChip(
          label: const Text('العربية'),
          selected: language == CourseWorkspaceLanguage.arabic,
          onSelected: (_) => onChanged(CourseWorkspaceLanguage.arabic),
        ),
      ],
    );
  }
}

class SeverityBadge extends StatelessWidget {
  const SeverityBadge(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final tone = label.toLowerCase();
    final color = switch (tone) {
      'high' => AppColors.danger,
      'medium' => AppColors.warning,
      _ => AppColors.info,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}

class QuickActionTile extends StatelessWidget {
  const QuickActionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      interactive: true,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.flash_on_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Icon(icon, color: Theme.of(context).iconTheme.color),
        ],
      ),
    );
  }
}

class EmptyWorkspaceState extends StatelessWidget {
  const EmptyWorkspaceState({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.inbox_rounded, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnnouncementPreviewCard extends StatelessWidget {
  const AnnouncementPreviewCard({
    super.key,
    required this.item,
    required this.copy,
    required this.onEdit,
    required this.onTogglePublish,
    required this.onDelete,
  });

  final CourseAnnouncement item;
  final CourseWorkspaceCopy copy;
  final VoidCallback onEdit;
  final VoidCallback onTogglePublish;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                    StatusBadge(_priorityLabel(copy, item.priority)),
                    StatusBadge(
                      item.isPublished
                          ? copy.text('Published', 'منشور')
                          : copy.text('Unpublished', 'غير منشور'),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'toggle') onTogglePublish();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(copy.text('Edit', 'تعديل')),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Text(
                      item.isPublished
                          ? copy.text('Unpublish', 'إلغاء النشر')
                          : copy.text('Publish', 'نشر'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(copy.text('Delete', 'حذف')),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(item.body, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            DateFormat('dd MMM yyyy • hh:mm a').format(item.publishedAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (item.attachmentUrl != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              item.attachmentUrl!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.info,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _priorityLabel(
    CourseWorkspaceCopy copy,
    CourseAnnouncementPriority priority,
  ) {
    return switch (priority) {
      CourseAnnouncementPriority.normal => copy.text('Normal', 'عادي'),
      CourseAnnouncementPriority.important => copy.text('Important', 'مهم'),
      CourseAnnouncementPriority.urgent => copy.text('Urgent', 'عاجل'),
    };
  }
}

class SessionLinkCard extends StatelessWidget {
  const SessionLinkCard({
    super.key,
    required this.item,
    required this.copy,
  });

  final CourseSessionLink item;
  final CourseWorkspaceCopy copy;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              item.kind == CourseSessionKind.lecture
                  ? Icons.co_present_rounded
                  : Icons.groups_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                    StatusBadge(
                      item.kind == CourseSessionKind.lecture
                          ? copy.text('Lecture', 'محاضرة')
                          : copy.text('Section', 'سكشن'),
                    ),
                    StatusBadge(
                      item.deliveryMode == CourseDeliveryMode.online
                          ? copy.text('Online', 'أونلاين')
                          : copy.text('Offline', 'أوفلاين'),
                    ),
                    StatusBadge(
                      item.isPublished
                          ? copy.text('Published', 'منشور')
                          : copy.text('Draft', 'مسودة'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(item.description, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  DateFormat('dd MMM yyyy • hh:mm a').format(item.scheduledAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (item.meetingLink != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.meetingLink!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ],
                if (item.locationLabel != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.locationLabel!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GroupPostCard extends StatelessWidget {
  const GroupPostCard({
    super.key,
    required this.post,
    required this.copy,
    required this.commentController,
    required this.onAddComment,
  });

  final CourseGroupPost post;
  final CourseWorkspaceCopy copy;
  final TextEditingController commentController;
  final VoidCallback onAddComment;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withValues(alpha: .14),
                child: Text(
                  post.authorName.characters.first.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.authorName, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      DateFormat('dd MMM • hh:mm a').format(post.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              StatusBadge(_visibilityLabel(copy, post.visibility)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(post.body, style: Theme.of(context).textTheme.bodyMedium),
          if (post.attachmentUrl != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              post.attachmentUrl!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.info,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              StatusBadge('${post.comments.length} ${copy.text('comments', 'تعليقات')}'),
              StatusBadge('${post.reactionCount} ${copy.text('reactions', 'تفاعلات')}'),
            ],
          ),
          if (post.comments.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            for (final comment in post.comments) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest
                      .withValues(alpha: .45),
                  borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.authorName,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(comment.body),
                  ],
                ),
              ),
            ],
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: copy.text('Write a comment', 'اكتب تعليقًا'),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              PremiumButton(
                label: copy.text('Comment', 'تعليق'),
                icon: Icons.send_rounded,
                onPressed: onAddComment,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _visibilityLabel(
    CourseWorkspaceCopy copy,
    CoursePostVisibility visibility,
  ) {
    return switch (visibility) {
      CoursePostVisibility.enrolled => copy.text('All students', 'كل الطلبة'),
      CoursePostVisibility.sectionsOnly => copy.text('Sections only', 'السكاشن فقط'),
      CoursePostVisibility.assistantsOnly => copy.text('Assistants', 'المعيدون'),
    };
  }
}

class StudentPreviewCard extends StatelessWidget {
  const StudentPreviewCard({
    super.key,
    required this.student,
    required this.copy,
    required this.selected,
    required this.onTap,
  });

  final CourseStudent student;
  final CourseWorkspaceCopy copy;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      interactive: true,
      onTap: onTap,
      backgroundColor: selected
          ? AppColors.primary.withValues(alpha: .08)
          : Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(student.code, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              StatusBadge(_engagementLabel(copy, student.engagement)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(student.activitySummary, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${copy.text('Quiz completion', 'إكمال الكويزات')}: ${student.quizCompletionRate}%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            '${copy.text('Submissions', 'التسليمات')}: ${student.submissionsCount}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _engagementLabel(
    CourseWorkspaceCopy copy,
    CourseEngagementLevel level,
  ) {
    return switch (level) {
      CourseEngagementLevel.high => copy.text('High', 'مرتفع'),
      CourseEngagementLevel.medium => copy.text('Medium', 'متوسط'),
      CourseEngagementLevel.low => copy.text('Low', 'منخفض'),
    };
  }
}

class StudentDetailsPanel extends StatelessWidget {
  const StudentDetailsPanel({
    super.key,
    required this.student,
    required this.copy,
  });

  final CourseStudent student;
  final CourseWorkspaceCopy copy;

  @override
  Widget build(BuildContext context) {
    return WorkspaceSectionCard(
      title: student.name,
      subtitle: '${student.code} • ${student.email}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(student.activitySummary),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              StatusBadge(
                '${copy.text('Quiz completion', 'إكمال الكويزات')} ${student.quizCompletionRate}%',
              ),
              StatusBadge(
                '${copy.text('Sheets', 'الشيتات')} ${student.completedSheets}',
              ),
              StatusBadge(
                '${copy.text('Completed quizzes', 'الكويزات المكتملة')} ${student.completedQuizzes}',
              ),
              StatusBadge(
                '${copy.text('Average', 'المتوسط')} ${student.averageGrade.toStringAsFixed(1)}%',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${copy.text('Last active', 'آخر نشاط')}: ${DateFormat('dd MMM yyyy • hh:mm a').format(student.lastActive)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
