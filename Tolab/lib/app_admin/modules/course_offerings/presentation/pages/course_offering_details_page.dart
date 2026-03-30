import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../shared/dialogs/app_confirm_dialog.dart';
import '../../../../shared/enums/load_status.dart';
import '../../../../shared/widgets/async_state_view.dart';
import '../../../../shared/widgets/premium_button.dart';
import '../../../../state/app_state.dart';
import '../../models/course_offering_model.dart';
import '../../state/course_offerings_actions.dart';
import '../../state/course_offerings_selectors.dart';
import '../widgets/offering_form.dart';
import '../widgets/offering_tabs.dart';

class CourseOfferingDetailsPage extends StatelessWidget {
  const CourseOfferingDetailsPage({super.key, required this.offeringId});

  final String offeringId;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _CourseOfferingDetailsViewModel>(
      onInit: (store) {
        store.dispatch(const FetchCourseOfferingsAction(silent: true));
        store.dispatch(FetchCourseOfferingDetailsAction(offeringId));
      },
      converter: (store) =>
          _CourseOfferingDetailsViewModel.fromStore(store, offeringId),
      distinct: true,
      builder: (context, vm) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.go(RoutePaths.courseOfferings),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vm.offering?.subjectName ?? 'Offering details',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vm.offering == null
                            ? 'Loading course offering details.'
                            : '${vm.offering!.code} - ${vm.offering!.sectionName} - ${vm.offering!.semester} ${vm.offering!.academicYear}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (vm.offering != null) ...[
                  PremiumButton(
                    label: 'Edit',
                    icon: Icons.edit_outlined,
                    isSecondary: true,
                    onPressed: () => OfferingForm.show(
                      context,
                      initialOffering: vm.offering,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  PremiumButton(
                    label: 'Delete',
                    icon: Icons.delete_outline_rounded,
                    isSecondary: true,
                    onPressed: () => _delete(context, vm.store, vm.offering!),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: AsyncStateView(
                status: vm.status,
                errorMessage: vm.errorMessage,
                onRetry: () => vm.store.dispatch(
                  FetchCourseOfferingDetailsAction(offeringId),
                ),
                isEmpty: vm.offering == null && vm.status == LoadStatus.success,
                emptyTitle: 'Offering not found',
                emptySubtitle:
                    'The selected course offering is no longer available in the current workspace snapshot.',
                child: vm.offering == null
                    ? const SizedBox.shrink()
                    : OfferingTabs(
                        offering: vm.offering!,
                        activeTab: vm.activeTab,
                        onTabChanged: (tab) => vm.store.dispatch(
                          CourseOfferingDetailsTabChangedAction(tab),
                        ),
                        onAddStudent: () => _showPlaceholder(
                          context,
                          'Student enrollment controls are ready for backend integration.',
                        ),
                        onRemoveStudent: (_) => _showPlaceholder(
                          context,
                          'Student removal controls are ready for backend integration.',
                        ),
                        onQuickAction: (action) => _showPlaceholder(
                          context,
                          '${action.title} is ready for content module integration.',
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _delete(
    BuildContext context,
    Store<AppState> store,
    CourseOfferingModel offering,
  ) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: 'Delete offering',
      message: 'Delete ${offering.code} - ${offering.subjectName}?',
    );
    if (!confirmed || !context.mounted) return;
    store.dispatch(
      DeleteCourseOfferingAction(
        offeringId: offering.id,
        onSuccess: () {
          if (context.mounted) context.go(RoutePaths.courseOfferings);
        },
      ),
    );
  }

  void _showPlaceholder(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CourseOfferingDetailsViewModel {
  const _CourseOfferingDetailsViewModel({
    required this.store,
    required this.status,
    required this.activeTab,
    this.offering,
    this.errorMessage,
  });

  final Store<AppState> store;
  final LoadStatus status;
  final CourseOfferingDetailsTab activeTab;
  final CourseOfferingModel? offering;
  final String? errorMessage;

  factory _CourseOfferingDetailsViewModel.fromStore(
    Store<AppState> store,
    String offeringId,
  ) {
    final state = store.state.courseOfferingsState;
    return _CourseOfferingDetailsViewModel(
      store: store,
      status: state.detailsStatus == LoadStatus.initial
          ? state.status
          : state.detailsStatus,
      activeTab: state.activeTab,
      offering: selectOfferingById(state, offeringId),
      errorMessage: state.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _CourseOfferingDetailsViewModel &&
        other.status == status &&
        other.activeTab == activeTab &&
        other.errorMessage == errorMessage &&
        other.offering?.id == offering?.id &&
        other.offering?.status == offering?.status &&
        other.offering?.enrolledCount == offering?.enrolledCount &&
        listEquals(
          other.offering?.students.map((item) => item.id).toList() ?? const [],
          offering?.students.map((item) => item.id).toList() ?? const [],
        );
  }

  @override
  int get hashCode => Object.hash(
    status,
    activeTab,
    errorMessage,
    offering?.id,
    offering?.status,
    offering?.enrolledCount,
  );
}
