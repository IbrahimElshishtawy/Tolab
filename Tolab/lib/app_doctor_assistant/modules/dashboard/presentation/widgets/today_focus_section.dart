import 'package:flutter/material.dart';

import '../../../../core/models/dashboard_models.dart';
import '../theme/app_spacing.dart';
import '../theme/dashboard_theme_tokens.dart';
import 'dashboard_section_primitives.dart';

class TodayFocusSection extends StatelessWidget {
  const TodayFocusSection({
    super.key,
    required this.focus,
    required this.onOpenRoute,
  });

  final DashboardTodayFocus focus;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final tokens = DashboardThemeTokens.of(context);
    return DashboardSectionCard(
      title: 'Today Focus',
      subtitle: focus.summary,
      isHero: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            focus.headline,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: DashboardAppSpacing.md),
          DashboardMetricWrap(
            children: focus.metrics
                .map(
                  (metric) => DashboardMiniMetricCard(
                    label: metric.label,
                    value: metric.value,
                    tone: metric.tone,
                  ),
                )
                .toList(),
          ),
          if (focus.primaryAction != null) ...[
            const SizedBox(height: DashboardAppSpacing.md),
            FilledButton.icon(
              onPressed: () => onOpenRoute(focus.primaryAction!.route),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(focus.primaryAction!.ctaLabel),
            ),
          ],
        ],
      ),
    );
  }
}
