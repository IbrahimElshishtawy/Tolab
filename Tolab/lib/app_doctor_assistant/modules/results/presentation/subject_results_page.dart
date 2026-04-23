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

class SubjectResultsPage extends StatelessWidget {
  const SubjectResultsPage({super.key, required this.subjectId});

  final int subjectId;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<DoctorAssistantAppState, _SubjectResultsVm>(
      onInit: (store) => store.dispatch(LoadSubjectResultsAction(subjectId)),
      converter: (store) => _SubjectResultsVm.fromStore(store, subjectId),
      builder: (context, vm) {
        if (vm.user == null) {
          return const SizedBox.shrink();
        }

        return DoctorAssistantShell(
          user: vm.user!,
          activeRoute: AppRoutes.results,
          unreadNotifications: 0,
          child: DoctorAssistantPageScaffold(
            title: 'Subject Results',
            subtitle:
                'View grade structure, recent activity, and role-based grading controls for the selected subject.',
            breadcrumbs: const ['Workspace', 'Results', 'Subject'],
            child: _buildBody(context, vm),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, _SubjectResultsVm vm) {
    final results = vm.state.data;
    if (vm.state.status == ViewStatus.loading && results == null) {
      return const LoadingStateView(lines: 3);
    }
    if (vm.state.status == ViewStatus.failure && results == null) {
      return ErrorStateView(
        message: vm.state.error ?? 'Unable to load subject results.',
        onRetry: vm.reload,
      );
    }
    if (results == null) {
      return const EmptyStateView(
        title: 'No subject results',
        message: 'Grading categories will appear here once result data is available.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${results.subjectCode} · ${results.subjectName}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            PremiumButton(
              label: 'Manage grades',
              icon: Icons.table_rows_rounded,
              onPressed: () => context.go(AppRoutes.gradeEntry(subjectId)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GradingSummaryCards(analytics: results.analytics),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: results.categories
              .map(
                (category) => SizedBox(
                  width: 280,
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                category.label,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            StatusBadge(category.statusLabel),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Average ${category.averageScore.toStringAsFixed(1)} / ${category.maxScore.toStringAsFixed(0)}',
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${category.gradedCount} graded · ${category.missingCount} missing',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          category.isEditable ? 'Editable for this role' : 'View only for this role',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: AppSpacing.md),
        DoctorAssistantPanel(
          title: 'Recent grading activity',
          subtitle:
              'Recent draft, review, and published actions attached to this subject.',
          child: Column(
            children: results.recentActivity
                .map(
                  (activity) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: DoctorAssistantItemCard(
                      icon: Icons.grading_rounded,
                      title: activity.title,
                      subtitle: activity.subtitle,
                      meta: activity.createdAt.toIso8601String(),
                      statusLabel: activity.statusLabel,
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

class _SubjectResultsVm {
  const _SubjectResultsVm({
    required this.user,
    required this.state,
    required this.reload,
  });

  final dynamic user;
  final AsyncState<SubjectResultsModel> state;
  final VoidCallback reload;

  factory _SubjectResultsVm.fromStore(Store<DoctorAssistantAppState> store, int subjectId) {
    return _SubjectResultsVm(
      user: getCurrentUser(store.state),
      state: store.state.resultsState.subject,
      reload: () => store.dispatch(LoadSubjectResultsAction(subjectId)),
    );
  }
}
