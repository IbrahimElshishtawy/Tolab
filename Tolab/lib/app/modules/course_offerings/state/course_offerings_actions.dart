import 'package:flutter/foundation.dart';

import '../models/course_offering_model.dart';

class FetchCourseOfferingsAction {
  const FetchCourseOfferingsAction({this.silent = false});

  final bool silent;
}

class CourseOfferingsLoadedAction {
  const CourseOfferingsLoadedAction(this.bundle);

  final CourseOfferingsBundle bundle;
}

class CourseOfferingsFailedAction {
  const CourseOfferingsFailedAction(this.message);

  final String message;
}

class CourseOfferingsFiltersChangedAction {
  const CourseOfferingsFiltersChangedAction(this.filters);

  final CourseOfferingsFilters filters;
}

class CourseOfferingsPaginationChangedAction {
  const CourseOfferingsPaginationChangedAction(this.pagination);

  final CourseOfferingsPagination pagination;
}

class FetchCourseOfferingDetailsAction {
  const FetchCourseOfferingDetailsAction(this.offeringId);

  final String offeringId;
}

class CourseOfferingDetailsLoadedAction {
  const CourseOfferingDetailsLoadedAction(this.offering);

  final CourseOfferingModel offering;
}

class CourseOfferingDetailsFailedAction {
  const CourseOfferingDetailsFailedAction(this.message);

  final String message;
}

class CourseOfferingDetailsTabChangedAction {
  const CourseOfferingDetailsTabChangedAction(this.tab);

  final CourseOfferingDetailsTab tab;
}

class CreateCourseOfferingAction {
  const CreateCourseOfferingAction({
    required this.payload,
    this.onSuccess,
    this.onError,
  });

  final CourseOfferingUpsertPayload payload;
  final VoidCallback? onSuccess;
  final ValueChanged<String>? onError;
}

class UpdateCourseOfferingAction {
  const UpdateCourseOfferingAction({
    required this.offeringId,
    required this.payload,
    this.onSuccess,
    this.onError,
  });

  final String offeringId;
  final CourseOfferingUpsertPayload payload;
  final VoidCallback? onSuccess;
  final ValueChanged<String>? onError;
}

class DeleteCourseOfferingAction {
  const DeleteCourseOfferingAction({
    required this.offeringId,
    this.onSuccess,
    this.onError,
  });

  final String offeringId;
  final VoidCallback? onSuccess;
  final ValueChanged<String>? onError;
}

class CourseOfferingMutationStartedAction {
  const CourseOfferingMutationStartedAction();
}

class CourseOfferingMutationSucceededAction {
  const CourseOfferingMutationSucceededAction(this.result);

  final CourseOfferingMutationResult result;
}

class CourseOfferingMutationFailedAction {
  const CourseOfferingMutationFailedAction(this.message);

  final String message;
}

class ResetCourseOfferingFeedbackAction {
  const ResetCourseOfferingFeedbackAction();
}
