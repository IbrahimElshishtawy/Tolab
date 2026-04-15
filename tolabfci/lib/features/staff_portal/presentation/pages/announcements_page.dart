import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/repositories/mock_staff_portal_repository.dart';
import '../../domain/models/staff_portal_models.dart';
import '../providers/staff_portal_providers.dart';
import 'add_announcement_page.dart';

class AnnouncementsPage extends ConsumerWidget {
  const AnnouncementsPage({
    super.key,
    required this.subjectId,
    required this.items,
  });

  final String subjectId;
  final List<StaffAnnouncement> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.tr('أخبار وإعلانات المقرر', 'Course announcements'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            AppButton(
              label: context.tr('إضافة إعلان', 'Add announcement'),
              icon: Icons.add_rounded,
              isExpanded: false,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddAnnouncementPage(subjectId: subjectId),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (items.isEmpty)
          AppCard(
            child: Text(
              context.tr(
                'لا توجد إعلانات بعد. ابدأ بإضافة أول إعلان للمادة.',
                'No announcements yet. Publish the first course update.',
              ),
            ),
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        AppBadge(
                          label: _priorityLabel(context, item.priority),
                          foregroundColor: _priorityColor(item.priority),
                          backgroundColor: _priorityColor(
                            item.priority,
                          ).withValues(alpha: 0.14),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        AppBadge(
                          label: item.isPublished
                              ? context.tr('منشور', 'Published')
                              : context.tr('مسودة', 'Draft'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(item.content),
                    if (item.attachmentLabel != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        context.tr(
                          'مرفق: ${item.attachmentLabel}',
                          'Attachment: ${item.attachmentLabel}',
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Text(
                          item.authorName,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            await ref
                                .read(staffPortalRepositoryProvider)
                                .toggleAnnouncementPublication(
                                  subjectId: subjectId,
                                  announcementId: item.id,
                                );
                            ref.invalidate(
                              staffSubjectWorkspaceProvider(subjectId),
                            );
                            ref.invalidate(staffDashboardProvider);
                          },
                          child: Text(
                            item.isPublished
                                ? context.tr('إلغاء النشر', 'Unpublish')
                                : context.tr('نشر', 'Publish'),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AddAnnouncementPage(
                                  subjectId: subjectId,
                                  initialAnnouncement: item,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          onPressed: () async {
                            await ref
                                .read(staffPortalRepositoryProvider)
                                .deleteAnnouncement(
                                  subjectId: subjectId,
                                  announcementId: item.id,
                                );
                            ref.invalidate(
                              staffSubjectWorkspaceProvider(subjectId),
                            );
                            ref.invalidate(staffDashboardProvider);
                          },
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _priorityLabel(
    BuildContext context,
    StaffAnnouncementPriority priority,
  ) {
    return switch (priority) {
      StaffAnnouncementPriority.normal => context.tr('عادي', 'Normal'),
      StaffAnnouncementPriority.important => context.tr('مهم', 'Important'),
      StaffAnnouncementPriority.urgent => context.tr('عاجل', 'Urgent'),
    };
  }

  Color _priorityColor(StaffAnnouncementPriority priority) {
    return switch (priority) {
      StaffAnnouncementPriority.normal => AppColors.teal,
      StaffAnnouncementPriority.important => AppColors.warning,
      StaffAnnouncementPriority.urgent => AppColors.error,
    };
  }
}
