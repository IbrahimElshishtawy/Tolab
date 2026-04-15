import 'package:flutter/material.dart';

import '../../../app/localization/app_localizations.dart';
import '../colors/app_colors.dart';
import '../responsive/app_breakpoints.dart';
import '../spacing/app_spacing.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions = const [],
    this.breadcrumbs = const [],
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;
  final List<String> breadcrumbs;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            AppBreakpoints.isMobile(context) || constraints.maxWidth < 1040;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (breadcrumbs.isNotEmpty)
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  for (var index = 0; index < breadcrumbs.length; index++) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.byValue(breadcrumbs[index]),
                        style: textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    if (index != breadcrumbs.length - 1)
                      Text('/', style: textTheme.labelMedium),
                  ],
                ],
              ),
            if (breadcrumbs.isNotEmpty) const SizedBox(height: AppSpacing.md),
            if (isCompact)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.byValue(title), style: textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.xs),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Text(
                      l10n.byValue(subtitle),
                      style: textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: actions,
                    ),
                  ],
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.byValue(title),
                          style: textTheme.headlineMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: Text(
                            l10n.byValue(subtitle),
                            style: textTheme.bodyMedium?.copyWith(
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (actions.isNotEmpty) ...[
                    const SizedBox(width: AppSpacing.md),
                    Flexible(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          alignment: WrapAlignment.end,
                          children: actions,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
          ],
        );
      },
    );
  }
}
