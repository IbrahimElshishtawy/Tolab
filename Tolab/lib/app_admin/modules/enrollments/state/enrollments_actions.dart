import 'package:flutter/foundation.dart';

import '../models/enrollment_models.dart';

class FetchEnrollmentsAction {
  const FetchEnrollmentsAction({this.silent = false});

  final bool silent;
}

class EnrollmentsLoadedAction {
  const EnrollmentsLoadedAction(this.bundle);

  final EnrollmentsBundle bundle;
}

class EnrollmentsFailedAction {
  const EnrollmentsFailedAction(this.message);

  final String message;
}

class EnrollmentsFiltersChangedAction {
  const EnrollmentsFiltersChangedAction(this.filters);

  final EnrollmentsFilters filters;
}

class EnrollmentsSortChangedAction {
  const EnrollmentsSortChangedAction(this.sort);

  final EnrollmentsSort sort;
}

class EnrollmentsPaginationChangedAction {
  const EnrollmentsPaginationChangedAction(this.pagination);

  final EnrollmentsPagination pagination;
}

class EnrollmentSelectionToggledAction {
  const EnrollmentSelectionToggledAction({
    required this.enrollmentId,
    required this.selected,
  });

  final String enrollmentId;
  final bool selected;
}

class EnrollmentSelectionClearedAction {
  const EnrollmentSelectionClearedAction();
}

class CreateEnrollmentAction {
  const CreateEnrollmentAction({
    required this.payload,
    this.onSuccess,
    this.onError,
  });

  final EnrollmentUpsertPayload payload;
  final VoidCallback? onSuccess;
  final ValueChanged<String>? onError;
}

class UpdateEnrollmentAction {
  const UpdateEnrollmentAction({
    required this.enrollmentId,
    required this.payload,
    this.onSuccess,
    this.onError,
  });

  final String enrollmentId;
  final EnrollmentUpsertPayload payload;
  final VoidCallback? onSuccess;
  final ValueChanged<String>? onError;
}

class UpdateEnrollmentStatusAction {
  const UpdateEnrollmentStatusAction({
    required this.record,
    required this.status,
    this.onSuccess,
    this.onError,
  });

  final EnrollmentRecord record;
  final EnrollmentStatus status;
  final VoidCallback? onSuccess;
  final ValueChanged<String>? onError;
}

class DeleteEnrollmentAction {
  const DeleteEnrollmentAction({
    required this.enrollmentId,
    this.onSuccess,
    this.onError,
  });

  final String enrollmentId;
  final VoidCallback? onSuccess;
  final ValueChanged<String>? onError;
}

class SubmitBulkEnrollmentsAction {
  const SubmitBulkEnrollmentsAction({
    required this.payloads,
    this.onSuccess,
    this.onError,
  });

  final List<EnrollmentUpsertPayload> payloads;
  final VoidCallback? onSuccess;
  final ValueChanged<String>? onError;
}

class EnrollmentMutationStartedAction {
  const EnrollmentMutationStartedAction();
}

class EnrollmentMutationSucceededAction {
  const EnrollmentMutationSucceededAction(this.result);

  final EnrollmentMutationResult result;
}

class EnrollmentMutationFailedAction {
  const EnrollmentMutationFailedAction(this.message);

  final String message;
}

class ResetEnrollmentFeedbackAction {
  const ResetEnrollmentFeedbackAction();
}

class EnrollmentBulkPreviewPreparedAction {
  const EnrollmentBulkPreviewPreparedAction(this.preview);

  final EnrollmentBulkPreview preview;
}

class ClearEnrollmentBulkPreviewAction {
  const ClearEnrollmentBulkPreviewAction();
}
