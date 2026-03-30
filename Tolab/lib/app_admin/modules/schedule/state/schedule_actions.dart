import 'package:flutter/foundation.dart';

import '../models/schedule_models.dart';

class FetchScheduleAction {
  const FetchScheduleAction({this.silent = false});

  final bool silent;
}

class ScheduleLoadedAction {
  const ScheduleLoadedAction(this.bundle);

  final ScheduleBundle bundle;
}

class ScheduleFailedAction {
  const ScheduleFailedAction(this.message);

  final String message;
}

class ScheduleViewChangedAction {
  const ScheduleViewChangedAction(this.view);

  final ScheduleCalendarView view;
}

class ScheduleFocusedDayChangedAction {
  const ScheduleFocusedDayChangedAction(this.day);

  final DateTime day;
}

class ScheduleSelectedDayChangedAction {
  const ScheduleSelectedDayChangedAction(this.day);

  final DateTime day;
}

class ScheduleFiltersChangedAction {
  const ScheduleFiltersChangedAction(this.filters);

  final ScheduleFilters filters;
}

class ScheduleEventHighlightedAction {
  const ScheduleEventHighlightedAction(this.eventId);

  final String? eventId;
}

class CreateScheduleEventAction {
  const CreateScheduleEventAction({
    required this.payload,
    this.onSuccess,
    this.onError,
  });

  final ScheduleEventUpsertPayload payload;
  final VoidCallback? onSuccess;
  final ValueChanged<String>? onError;
}

class UpdateScheduleEventAction {
  const UpdateScheduleEventAction({
    required this.eventId,
    required this.payload,
    this.onSuccess,
    this.onError,
  });

  final String eventId;
  final ScheduleEventUpsertPayload payload;
  final VoidCallback? onSuccess;
  final ValueChanged<String>? onError;
}

class DeleteScheduleEventAction {
  const DeleteScheduleEventAction({
    required this.eventId,
    this.onSuccess,
    this.onError,
  });

  final String eventId;
  final VoidCallback? onSuccess;
  final ValueChanged<String>? onError;
}

class RescheduleScheduleEventAction {
  const RescheduleScheduleEventAction({
    required this.event,
    required this.targetStart,
    required this.targetEnd,
    this.onSuccess,
    this.onError,
  });

  final ScheduleEventItem event;
  final DateTime targetStart;
  final DateTime targetEnd;
  final VoidCallback? onSuccess;
  final ValueChanged<String>? onError;
}

class ScheduleMutationStartedAction {
  const ScheduleMutationStartedAction();
}

class ScheduleMutationSucceededAction {
  const ScheduleMutationSucceededAction(this.result);

  final ScheduleMutationResult result;
}

class ScheduleMutationFailedAction {
  const ScheduleMutationFailedAction(this.message);

  final String message;
}

class ClearScheduleFeedbackAction {
  const ClearScheduleFeedbackAction();
}
