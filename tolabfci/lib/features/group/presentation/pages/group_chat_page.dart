import 'package:flutter/material.dart';

import '../../../../core/localization/app_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../chat/presentation/widgets/chat_panel.dart';

class GroupChatPage extends StatelessWidget {
  const GroupChatPage({
    super.key,
    required this.subjectId,
    this.subjectName,
    this.embedded = false,
  });

  final String subjectId;
  final String? subjectName;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final content = Padding(
      padding: EdgeInsets.fromLTRB(
        embedded ? 0 : AppSpacing.md,
        embedded ? 0 : AppSpacing.sm,
        embedded ? 0 : AppSpacing.md,
        embedded ? 0 : MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (subjectName != null) ...[
            AppCard(
              backgroundColor: palette.surfaceElevated,
              child: Row(
                children: [
                  const Icon(Icons.groups_2_outlined, color: AppColors.primary),
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
    );

    if (embedded) {
      return SizedBox(height: 620, child: content);
    }

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        title: Text(context.tr('الجروب', 'Group Chat')),
        centerTitle: false,
      ),
      body: SafeArea(child: content),
    );
  }
}
