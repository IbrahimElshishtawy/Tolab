import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/repositories/mock_staff_portal_repository.dart';
import '../../domain/models/staff_portal_models.dart';
import '../providers/staff_portal_providers.dart';

class GroupActivityPage extends ConsumerWidget {
  const GroupActivityPage({
    super.key,
    required this.subjectId,
    required this.posts,
  });

  final String subjectId;
  final List<StaffGroupPost> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.tr('نشاط الجروب', 'Group activity'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            AppButton(
              label: context.tr('إضافة Post', 'Add post'),
              icon: Icons.edit_note_rounded,
              isExpanded: false,
              onPressed: () => _openComposer(context, ref),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (posts.isEmpty)
          AppCard(
            child: Text(
              context.tr(
                'لا توجد منشورات بعد. ابدأ رسالة موجّهة للطلبة أو المعيدين.',
                'No posts yet. Start with a course update or targeted message.',
              ),
            ),
          )
        else
          ...posts.map(
            (post) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.authorName,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                '${post.authorRole} • ${post.visibilityLabel}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${post.reactionsCount} reactions',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(post.content),
                    if (post.attachmentLabel != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        context.tr(
                          'مرفق: ${post.attachmentLabel}',
                          'Attachment: ${post.attachmentLabel}',
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    ...post.comments.map(
                      (comment) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '${comment.authorName}: ${comment.content}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _openCommentComposer(context, ref, post),
                      icon: const Icon(Icons.add_comment_outlined),
                      label: Text(context.tr('إضافة تعليق', 'Add comment')),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _openComposer(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final attachmentController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.tr('منشور جديد', 'New post')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                minLines: 3,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: context.tr('المحتوى', 'Content'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: attachmentController,
                decoration: InputDecoration(
                  labelText: context.tr('مرفق اختياري', 'Optional attachment'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.tr('إلغاء', 'Cancel')),
            ),
            FilledButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) {
                  return;
                }
                await ref
                    .read(staffPortalRepositoryProvider)
                    .savePost(
                      subjectId: subjectId,
                      post: StaffGroupPost(
                        id: '',
                        subjectId: subjectId,
                        authorName: 'Staff',
                        authorRole: 'Staff',
                        content: controller.text.trim(),
                        createdAt: DateTime.now(),
                        visibilityLabel: 'Course group',
                        reactionsCount: 0,
                        comments: const [],
                        attachmentLabel:
                            attachmentController.text.trim().isEmpty
                            ? null
                            : attachmentController.text.trim(),
                      ),
                    );
                ref.invalidate(staffSubjectWorkspaceProvider(subjectId));
                ref.invalidate(staffDashboardProvider);
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(context.tr('نشر', 'Post')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openCommentComposer(
    BuildContext context,
    WidgetRef ref,
    StaffGroupPost post,
  ) async {
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.tr('إضافة تعليق', 'Add comment')),
          content: TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: context.tr('التعليق', 'Comment'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.tr('إلغاء', 'Cancel')),
            ),
            FilledButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) {
                  return;
                }
                await ref
                    .read(staffPortalRepositoryProvider)
                    .addComment(
                      subjectId: subjectId,
                      postId: post.id,
                      comment: StaffGroupComment(
                        id: '',
                        authorName: 'Staff',
                        authorRole: 'Staff',
                        content: controller.text.trim(),
                        createdAt: DateTime.now(),
                      ),
                    );
                ref.invalidate(staffSubjectWorkspaceProvider(subjectId));
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(context.tr('إضافة', 'Add')),
            ),
          ],
        );
      },
    );
  }
}
