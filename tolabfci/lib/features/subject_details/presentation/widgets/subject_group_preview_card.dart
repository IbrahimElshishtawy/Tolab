import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../providers/chat_providers.dart';
import '../providers/community_providers.dart';

class SubjectGroupPreviewCard extends ConsumerWidget {
  const SubjectGroupPreviewCard({
    super.key,
    required this.subjectId,
    required this.onOpenGroup,
  });

  final String subjectId;
  final VoidCallback onOpenGroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(communityControllerProvider(subjectId));
    final chatAsync = ref.watch(chatControllerProvider(subjectId));
    final notifications =
        ref.watch(notificationsStreamProvider).value ?? const [];
    final unreadCount = notifications.where((item) {
      return !item.isRead &&
          item.pathParameters['subjectId'] == subjectId &&
          item.category.contains('الجروب');
    }).length;

    return postsAsync.when(
      data: (posts) {
        final latestPost = posts.isEmpty ? null : posts.first;
        final messages = chatAsync.asData?.value.messages;
        final latestMessage = messages == null || messages.isEmpty
            ? null
            : messages.last;

        return AppCard(
          backgroundColor: context.appColors.surfaceElevated,
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 680;
              final preview = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'الجروب / Course Group',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (unreadCount > 0)
                        AppBadge(
                          label: '$unreadCount غير مقروء',
                          backgroundColor: AppColors.warning.withValues(
                            alpha: 0.12,
                          ),
                          foregroundColor: AppColors.warning,
                          dense: true,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _PreviewLine(
                    icon: Icons.push_pin_outlined,
                    label: 'آخر منشور',
                    value: latestPost == null
                        ? 'لا توجد منشورات بعد'
                        : '${latestPost.authorName} • ${latestPost.title ?? latestPost.preview ?? latestPost.content}',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _PreviewLine(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'آخر رسالة',
                    value: latestMessage == null
                        ? 'لا توجد رسائل بعد'
                        : '${latestMessage.authorName} • ${latestMessage.content} • ${latestMessage.sentAtLabel}',
                  ),
                ],
              );

              final action = AppButton(
                label: 'فتح الجروب',
                onPressed: onOpenGroup,
                isExpanded: compact,
                icon: Icons.open_in_new_rounded,
                variant: AppButtonVariant.secondary,
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    preview,
                    const SizedBox(height: AppSpacing.sm),
                    action,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.forum_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: preview),
                  const SizedBox(width: AppSpacing.sm),
                  action,
                ],
              );
            },
          ),
        );
      },
      loading: () => const AppCard(
        child: SizedBox(
          height: 72,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
      error: (error, _) => AppCard(
        child: Text(
          error.toString(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}

class _PreviewLine extends StatelessWidget {
  const _PreviewLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.primary),
        const SizedBox(width: AppSpacing.xs),
        Text('$label: ', style: Theme.of(context).textTheme.labelLarge),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
