import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../../../shared/dialogs/app_confirm_dialog.dart';
import '../../../../shared/enums/load_status.dart';
import '../../../../shared/widgets/async_state_view.dart';
import '../../../../state/app_state.dart';
import '../../models/course_offering_model.dart';
import '../../state/course_offerings_actions.dart';
import '../models/course_offering_details_view_model.dart';
import '../widgets/offering_form.dart';
import '../widgets/offering_tabs.dart';
import '../widgets/course_offering_details_header.dart';

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
    return StoreConnector<AppState, CourseOfferingDetailsViewModel>(
      onInit: (store) {
        store.dispatch(const FetchCourseOfferingsAction(silent: true));
        store.dispatch(FetchCourseOfferingDetailsAction(widget.offeringId));
      },
      converter: (store) =>
          CourseOfferingDetailsViewModel.fromStore(store, widget.offeringId),
      distinct: true,
      builder: (context, vm) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CourseOfferingDetailsHeader(
              offering: vm.offering,
              onClose: () => _closeDetails(context),
              onEdit: () => OfferingForm.show(
                context,
                initialOffering: vm.offering,
              ),
              onDelete: () {
                if (vm.offering != null) {
                  _delete(context, vm.store, vm.offering!);
                }
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
          if (context.mounted) _closeDetails(context);
        },
      ),
    );
  }

  void _closeDetails(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(RoutePaths.courseOfferings);
  }

  void _showPlaceholder(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
