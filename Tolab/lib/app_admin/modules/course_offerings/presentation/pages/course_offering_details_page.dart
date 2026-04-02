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

class CourseOfferingDetailsPage extends StatefulWidget {
  const CourseOfferingDetailsPage({super.key, required this.offeringId});

  final String offeringId;

  @override
  State<CourseOfferingDetailsPage> createState() =>
      _CourseOfferingDetailsPageState();
}

class _CourseOfferingDetailsPageState extends State<CourseOfferingDetailsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _CourseOfferingDetailsViewModel>(
      onInit: (store) {
        store.dispatch(const FetchCourseOfferingsAction(silent: true));
        store.dispatch(FetchCourseOfferingDetailsAction(widget.offeringId));
      },
      converter: (store) =>
          _CourseOfferingDetailsViewModel.fromStore(store, widget.offeringId),
      distinct: true,
      builder: (context, vm) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 760;
                final titleBlock = Column(
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
                );
                final actions = vm.offering == null
                    ? const <Widget>[]
                    : [
                        PremiumButton(
                          label: 'Edit',
                          icon: Icons.edit_outlined,
                          isSecondary: true,
                          onPressed: () => OfferingForm.show(
                            context,
                            initialOffering: vm.offering,
                          ),
                        ),
                        PremiumButton(
                          label: 'Delete',
                          icon: Icons.delete_outline_rounded,
                          isSecondary: true,
                          onPressed: () =>
                              _delete(context, vm.store, vm.offering!),
                        ),
                      ];

                return compact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () =>
                                context.go(RoutePaths.courseOfferings),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          titleBlock,
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
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () =>
                                context.go(RoutePaths.courseOfferings),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: titleBlock),
                          if (actions.isNotEmpty) ...[
                            const SizedBox(width: AppSpacing.md),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: actions,
                            ),
                          ],
                        ],
                      );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: AsyncStateView(
                status: vm.status,
                errorMessage: vm.errorMessage,
                onRetry: () => vm.store.dispatch(
                  FetchCourseOfferingDetailsAction(widget.offeringId),
                ),
                isEmpty: vm.offering == null && vm.status == LoadStatus.success,
                emptyTitle: 'Offering not found',
                emptySubtitle:
                    'The selected course offering is no longer available in the current workspace snapshot.',
                child: vm.offering == null
                    ? const SizedBox.shrink()
                    : Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: OfferingTabs(
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
