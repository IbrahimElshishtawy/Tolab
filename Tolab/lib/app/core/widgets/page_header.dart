import 'package:flutter/material.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (breadcrumbs.isNotEmpty)
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              for (final crumb in breadcrumbs)
                Text(crumb, style: textTheme.labelMedium),
            ],
          ),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: textTheme.bodyMedium),
                ],
              ),
            ),
            Wrap(spacing: AppSpacing.sm, children: actions),
          ],
        ),
      ],
    );
  }
}
