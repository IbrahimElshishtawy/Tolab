import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../chat/presentation/widgets/chat_panel.dart';
import '../../../subjects/presentation/providers/subjects_providers.dart';

class SubjectGroupChatTab extends ConsumerWidget {
  const SubjectGroupChatTab({
    super.key,
    required this.subjectId,
    this.usePageScroll = false,
  });

  final String subjectId;
  final bool usePageScroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subject = ref.watch(subjectByIdProvider(subjectId)).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          backgroundColor: context.appColors.surfaceElevated,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.groups_2_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject == null ? 'جروب المادة' : 'جروب ${subject.name}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'الرسائل تظهر لطلاب المادة المسجلين فقط',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const AppBadge(
                label: '37 online',
                foregroundColor: AppColors.success,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ChatPanel(
          subjectId: subjectId,
          fillAvailable: !usePageScroll,
          showHeader: false,
        ),
      ],
    );
  }
}
