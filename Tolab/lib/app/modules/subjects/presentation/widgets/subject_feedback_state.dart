import 'package:flutter/material.dart';

import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../design/subjects_management_tokens.dart';

class SubjectFeedbackState extends StatelessWidget {
  const SubjectFeedbackState({
    super.key,
    required this.title,
    required this.message,
    this.action,
  });

  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: SubjectsManagementDecorations.tintedPanel(
              context,
              tint: SubjectsManagementPalette.accent,
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: SubjectsManagementPalette.accent,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.lg),
            action!,
          ],
        ],
      ),
    );
  }
}
