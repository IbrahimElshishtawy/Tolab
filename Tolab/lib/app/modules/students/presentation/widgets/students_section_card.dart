import 'package:flutter/material.dart';

import '../../../../core/spacing/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';

class StudentsSectionCard extends StatelessWidget {
  const StudentsSectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.interactive = false,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final bool interactive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding,
      interactive: interactive,
      onTap: onTap,
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
                    const SizedBox(height: 6),
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
