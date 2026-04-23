import 'package:flutter/material.dart';

import '../../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../models/analytics_workspace_models.dart';

class AnalyticsAlertsSection extends StatelessWidget {
  const AnalyticsAlertsSection({super.key, required this.alerts});

  final List<AnalyticsAlertItem> alerts;

  @override
  Widget build(BuildContext context) {
    return DoctorAssistantPanel(
      title: 'Smart alerts',
      subtitle:
          alerts.isEmpty
              ? 'No urgent academic warnings are active right now.'
              : 'Signals that deserve an intervention before the next lecture, quiz, or publication cycle.',
      child: alerts.isEmpty
          ? const DoctorAssistantEmptyState(
              title: 'No urgent alerts',
              subtitle:
                  'The current mock dataset is inside normal academic thresholds.',
            )
          : Column(
              children: alerts
                  .map(
                    (alert) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: DoctorAssistantItemCard(
                        icon: alert.icon,
                        title: alert.title,
                        subtitle: alert.severity.label,
                        meta: alert.description,
                        statusLabel: alert.severity.label,
                        highlightColor: alert.severity.color,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}
