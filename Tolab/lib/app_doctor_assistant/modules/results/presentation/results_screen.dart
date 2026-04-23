import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';

import '../../../../app_admin/core/spacing/app_spacing.dart';
import '../../../../app_admin/core/widgets/app_card.dart';
import '../../../../app_admin/shared/widgets/premium_button.dart';
import '../../../../app_admin/shared/widgets/status_badge.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/state/async_state.dart';
import '../../../core/widgets/state_views.dart';
import '../../../presentation/widgets/doctor_assistant_shell.dart';
import '../../../presentation/widgets/doctor_assistant_widgets.dart';
import '../../../state/app_state.dart';
import '../../auth/state/session_selectors.dart';
import '../models/results_models.dart';
import '../state/results_actions.dart';
import 'widgets/grading_summary_cards.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _ResultsVm>(
      onInit: (store) => store.dispatch(LoadResultsOverviewAction()),
      converter: (store) => _ResultsVm.fromStore(store),
      builder: (context, vm) {
        if (vm.user == null) {
          return const SizedBox.shrink();
        }

        return DoctorAssistantShell(
          user: vm.user!,
          activeRoute: AppRoutes.results,
          unreadNotifications: 0,
          child: DoctorAssistantPageScaffold(
            title: 'Results & Grading',
            subtitle:
                'Monitor published grades, pending review, and category-level readiness across assigned subjects.',
            breadcrumbs: const ['Workspace', 'Results'],
            child: _buildBody(context, vm),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, _ResultsVm vm) {
    final overview = vm.state.data;
    if (vm.state.status == ViewStatus.loading && overview == null) {
      return const LoadingStateView(lines: 4);
    }
    if (vm.state.status == ViewStatus.failure && overview == null) {
      return ErrorStateView(
        message: vm.state.error ?? 'Failed to load results overview.',
        onRetry: vm.reload,
      );
    }
    if (overview == null) {
      return const EmptyStateView(
        title: 'No grading data yet',
        message: 'Results will appear here once the first grading cycle starts.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradingSummaryCards(analytics: overview.analytics),
        const SizedBox(height: AppSpacing.md),
        DoctorAssistantPanel(
          title: 'Subjects',
          subtitle:
              'Each subject shows average score, pending review, and published results count.',
          child: Column(
            children: overview.subjects
                .map(
                  (subject) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: AppCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: AppSpacing.sm,
                                  runSpacing: AppSpacing.sm,
                                  children: [
                                    Text(
                                      '${subject.subjectCode} · ${subject.subjectName}',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    StatusBadge(subject.statusLabel),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Average ${subject.averageScore.toStringAsFixed(1)}% · ${subject.pendingReviewCount} pending review · ${subject.publishedResultsCount} published',
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  subject.latestActivityLabel,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          PremiumButton(
                            label: 'Open',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: () => context.go(
                              AppRoutes.subjectResults(subject.subjectId),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }
}

class _ResultsVm {
  const _ResultsVm({
    required this.user,
    required this.state,
    required this.reload,
  });

  final dynamic user;
  final AsyncState<ResultsOverviewModel> state;
  final VoidCallback reload;

  factory _ResultsVm.fromStore(Store<DoctorAssistantAppState> store) {
    return _ResultsVm(
      user: getCurrentUser(store.state),
      state: store.state.resultsState.overview,
      reload: () => store.dispatch(LoadResultsOverviewAction()),
    );
  }
}
