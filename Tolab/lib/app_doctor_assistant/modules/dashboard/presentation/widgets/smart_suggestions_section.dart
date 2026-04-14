import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import 'dashboard_section_primitives.dart';

class SmartSuggestionsSection extends StatelessWidget {
  const SmartSuggestionsSection({
    super.key,
    required this.suggestions,
    required this.onOpenRoute,
  });

  final DashboardSmartSuggestions suggestions;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    if (suggestions.items.isEmpty) {
      return const DashboardSectionCard(
        title: 'Smart Suggestions',
        child: DashboardSectionEmpty(
          message: 'Suggestions will appear when the dashboard detects patterns worth acting on.',
        ),
      );
    }

    return DashboardSectionCard(
      title: 'Smart Suggestions',
      child: Column(
        children: suggestions.items
            .map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.title),
                subtitle: Text(item.explanation),
                trailing: DashboardInlineAction(
                  label: item.ctaLabel,
                  onTap: () => onOpenRoute(item.route),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
