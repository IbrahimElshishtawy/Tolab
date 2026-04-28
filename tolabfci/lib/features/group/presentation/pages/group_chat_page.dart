import 'package:flutter/material.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../chat/presentation/widgets/chat_panel.dart';

class GroupChatPage extends StatelessWidget {
  const GroupChatPage({super.key, required this.subjectId, this.subjectName});

  final String subjectId;
  final String? subjectName;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: Text(context.tr('الجروب', 'Group Chat')),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (subjectName != null) ...[
                AppCard(
                  backgroundColor: palette.surfaceElevated,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.groups_2_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          subjectName!,
                          style: Theme.of(context).textTheme.titleLarge,
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
              ],
              Expanded(
                child: ChatPanel(
                  subjectId: subjectId,
                  fillAvailable: true,
                  compact: false,
                  showHeader: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
