import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../app_admin/shared/widgets/status_badge.dart';
import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';
import '../../../mock/mock_portal_models.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, SessionUser?>(
      converter: (store) => getCurrentUser(store.state),
      builder: (context, user) {
        if (user == null) {
          return const SizedBox.shrink();
        }

        final repository = DoctorAssistantMockRepository.instance;
        final analytics = repository.analyticsFor(user);

        return DoctorAssistantShell(
          user: user,
          activeRoute: AppRoutes.analytics,
          unreadNotifications: repository.unreadNotificationsFor(user),
          child: DoctorAssistantPageScaffold(
            title: 'Analytics',
            subtitle:
                'A premium mock analytics view built from local students, results, and subject health fixtures.',
            breadcrumbs: const ['Workspace', 'Analytics'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: analytics.kpis
                      .map((kpi) => _KpiCard(kpi: kpi))
                      .toList(growable: false),
                ),
                const SizedBox(height: AppSpacing.md),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 1000;
                    final left = DoctorAssistantPanel(
                      title: 'Activity trend',
                      subtitle: analytics.summary,
                      child: Column(
                        children: analytics.activityTrend
                            .map((point) => _TrendRow(point: point))
                            .toList(growable: false),
                      ),
                    );
                    final right = DoctorAssistantPanel(
                      title: 'Subject pulse',
                      subtitle:
                          'Completion and risk visibility by subject using mock aggregates.',
                      child: Column(
                        children: analytics.subjectPulse
                            .map((pulse) => _SubjectPulseCard(pulse: pulse))
                            .toList(growable: false),
                      ),
                    );

                    if (!isWide) {
                      return Column(
                        children: [
                          left,
                          const SizedBox(height: AppSpacing.md),
                          right,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: left),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: right),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.kpi});

  final MockAnalyticsKpi kpi;

  @override
  Widget build(BuildContext context) {
    final color = switch (kpi.tone) {
      'success' => const Color(0xFF14B8A6),
      'warning' => const Color(0xFFF59E0B),
      _ => const Color(0xFF2563EB),
    };

    return Container(
      width: 240,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(kpi.label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            kpi.value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          StatusBadge(kpi.deltaLabel),
        ],
      ),
    );
  }
}

class _TrendRow extends StatelessWidget {
  const _TrendRow({required this.point});

  final MockAnalyticsPoint point;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          SizedBox(width: 34, child: Text(point.label)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: point.value / 100,
                minHeight: 12,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('${point.value.toStringAsFixed(0)}%'),
        ],
      ),
    );
  }
}

class _SubjectPulseCard extends StatelessWidget {
  const _SubjectPulseCard({required this.pulse});

  final MockAnalyticsSubjectPulse pulse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: DoctorAssistantItemCard(
        icon: Icons.insights_rounded,
        title: '${pulse.subjectCode} - ${pulse.subjectName}',
        subtitle:
            'Health ${pulse.healthScore} - Completion ${pulse.completionRate}%',
        meta: 'Risk status: ${pulse.riskLabel}',
        statusLabel: pulse.riskLabel,
      ),
    );
  }
}
