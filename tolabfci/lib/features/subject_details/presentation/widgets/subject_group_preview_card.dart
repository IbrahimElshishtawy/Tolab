import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
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
    final notifications =
        ref.watch(notificationsStreamProvider).value ?? const [];
    final unreadCount = notifications.where((item) {
      return !item.isRead &&
          item.pathParameters['subjectId'] == subjectId &&
          item.category.contains('الجروب');
    }).length;

    return postsAsync.when(
      data: (posts) {
        final latest = posts.isEmpty ? null : posts.first;
        final title = latest?.title ?? 'الجروب / Course Group';
        final preview = latest?.preview ?? latest?.content;
        final meta = latest == null
            ? 'سيظهر آخر نشاط داخل مجتمع المادة هنا.'
            : '${latest.authorName} • ${latest.createdAtLabel}';

        return AppCard(
          backgroundColor: context.appColors.surfaceElevated,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.forum_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
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
                    const SizedBox(height: AppSpacing.xs),
                    Text(meta, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (preview != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppButton(
                label: 'فتح الجروب',
                onPressed: onOpenGroup,
                isExpanded: false,
                icon: Icons.arrow_forward_rounded,
                variant: AppButtonVariant.secondary,
              ),
            ],
          ),
        );
      },
      loading: () => const AppCard(
        child: SizedBox(
          height: 92,
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
