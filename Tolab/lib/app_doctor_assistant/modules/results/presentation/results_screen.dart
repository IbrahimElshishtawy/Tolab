import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../app_admin/shared/widgets/status_badge.dart';
import '../../../core/models/session_user.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../mock/doctor_assistant_mock_repository.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, SessionUser?>(
      converter: (store) => getCurrentUser(store.state),
      builder: (context, user) {
        if (user == null) {
          return const SizedBox.shrink();
        }

        final repository = DoctorAssistantMockRepository.instance;
        final results = repository.resultsFor(user);
        final average = results.isEmpty
            ? 0.0
            : results.fold<double>(0, (sum, item) => sum + item.percentage) /
                results.length;
        final publishedCount = results
            .where((item) => item.statusLabel.toLowerCase() == 'published')
            .length;
        final reviewCount = results
            .where((item) => item.statusLabel.toLowerCase().contains('review'))
            .length;

        return DoctorAssistantShell(
          user: user,
          activeRoute: AppRoutes.results,
          unreadNotifications: repository.unreadNotificationsFor(user),
          child: DoctorAssistantPageScaffold(
            title: 'Results',
            subtitle:
                'Local grading snapshots, publication status, and score visibility are all powered by mock data only.',
            breadcrumbs: const ['Workspace', 'Results'],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    _SummaryCard(
                      title: 'Average Score',
                      value: '${average.toStringAsFixed(1)}%',
                      toneColor: const Color(0xFF2563EB),
                    ),
                    _SummaryCard(
                      title: 'Published',
                      value: '$publishedCount',
                      toneColor: const Color(0xFF14B8A6),
                    ),
                    _SummaryCard(
                      title: 'Needs Review',
                      value: '$reviewCount',
                      toneColor: const Color(0xFFF59E0B),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                DoctorAssistantPanel(
                  title: 'Latest grading activity',
                  subtitle:
                      'A realistic review queue for quizzes, assignments, and published grades.',
                  child: Column(
                    children: results.map((result) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: DoctorAssistantItemCard(
                          icon: Icons.grading_rounded,
                          title: result.assessmentTitle,
                          subtitle:
                              '${result.studentName} (${result.studentCode}) - ${result.subjectCode}',
                          meta:
                              'Score ${result.score.toStringAsFixed(0)}/${result.maxScore.toStringAsFixed(0)} - ${result.percentage.toStringAsFixed(1)}%',
                          statusLabel: result.statusLabel,
                          trailing: StatusBadge(result.subjectName),
                        ),
                      );
                    }).toList(growable: false),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.toneColor,
  });

  final String title;
  final String value;
  final Color toneColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: toneColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: toneColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
