import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

import '../../../../shared/enums/load_status.dart';
import '../../../../state/app_state.dart';
import '../../models/course_offering_model.dart';
import '../../state/course_offerings_selectors.dart';

class CourseOfferingDetailsViewModel {
  const CourseOfferingDetailsViewModel({
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

  factory CourseOfferingDetailsViewModel.fromStore(
    Store<AppState> store,
    String offeringId,
  ) {
    final state = store.state.courseOfferingsState;
    return CourseOfferingDetailsViewModel(
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
    return other is CourseOfferingDetailsViewModel &&
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
