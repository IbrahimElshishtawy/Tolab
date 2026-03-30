import 'package:redux/redux.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/app_dependencies.dart';
import '../../../state/app_state.dart';
import '../models/enrollment_models.dart';
import 'enrollments_actions.dart';

List<Middleware<AppState>> createEnrollmentsMiddleware(AppDependencies deps) {
  return [
    TypedMiddleware<AppState, FetchEnrollmentsAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final state = store.state.enrollmentsState;
        final bundle = await deps.enrollmentsRepository.fetchEnrollments(
          filters: state.filters,
          sort: state.sort,
          pagination: state.pagination,
        );
        store.dispatch(EnrollmentsLoadedAction(bundle));
      } catch (error) {
        store.dispatch(EnrollmentsFailedAction(_messageOf(error)));
      }
    }).call,
    TypedMiddleware<AppState, CreateEnrollmentAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const EnrollmentMutationStartedAction());
      try {
        final state = store.state.enrollmentsState;
        final result = await deps.enrollmentsRepository.createEnrollment(
          payload: action.payload,
          filters: state.filters,
          sort: state.sort,
          pagination: state.pagination,
        );
        store.dispatch(EnrollmentMutationSucceededAction(result));
        await _notifyMutation(
          deps,
          result.message,
          'A new enrollment was added.',
        );
        action.onSuccess?.call();
      } catch (error) {
        final message = _messageOf(error);
        store.dispatch(EnrollmentMutationFailedAction(message));
        action.onError?.call(message);
      }
    }).call,
    TypedMiddleware<AppState, UpdateEnrollmentAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const EnrollmentMutationStartedAction());
      try {
        final state = store.state.enrollmentsState;
        final result = await deps.enrollmentsRepository.updateEnrollment(
          enrollmentId: action.enrollmentId,
          payload: action.payload,
          filters: state.filters,
          sort: state.sort,
          pagination: state.pagination,
        );
        store.dispatch(EnrollmentMutationSucceededAction(result));
        await _notifyMutation(
          deps,
          result.message,
          'Enrollment details were updated successfully.',
        );
        action.onSuccess?.call();
      } catch (error) {
        final message = _messageOf(error);
        store.dispatch(EnrollmentMutationFailedAction(message));
        action.onError?.call(message);
      }
    }).call,
    TypedMiddleware<AppState, UpdateEnrollmentStatusAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const EnrollmentMutationStartedAction());
      try {
        final state = store.state.enrollmentsState;
        final result = await deps.enrollmentsRepository.updateEnrollmentStatus(
          record: action.record,
          status: action.status,
          filters: state.filters,
          sort: state.sort,
          pagination: state.pagination,
        );
        store.dispatch(EnrollmentMutationSucceededAction(result));
        await _notifyMutation(
          deps,
          'Status changed to ${action.status.label}.',
          'Enrollment approval status changed.',
        );
        action.onSuccess?.call();
      } catch (error) {
        final message = _messageOf(error);
        store.dispatch(EnrollmentMutationFailedAction(message));
        action.onError?.call(message);
      }
    }).call,
    TypedMiddleware<AppState, DeleteEnrollmentAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const EnrollmentMutationStartedAction());
      try {
        final state = store.state.enrollmentsState;
        final result = await deps.enrollmentsRepository.deleteEnrollment(
          enrollmentId: action.enrollmentId,
          filters: state.filters,
          sort: state.sort,
          pagination: state.pagination,
        );
        store.dispatch(EnrollmentMutationSucceededAction(result));
        await _notifyMutation(
          deps,
          result.message,
          'Enrollment removed from the active roster.',
        );
        action.onSuccess?.call();
      } catch (error) {
        final message = _messageOf(error);
        store.dispatch(EnrollmentMutationFailedAction(message));
        action.onError?.call(message);
      }
    }).call,
    TypedMiddleware<AppState, SubmitBulkEnrollmentsAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const EnrollmentMutationStartedAction());
      try {
        final state = store.state.enrollmentsState;
        final result = await deps.enrollmentsRepository.bulkUpload(
          payloads: action.payloads,
          filters: state.filters,
          sort: state.sort,
          pagination: state.pagination,
        );
        store.dispatch(EnrollmentMutationSucceededAction(result));
        await _notifyMutation(
          deps,
          result.message,
          'Bulk enrollment import completed.',
        );
        action.onSuccess?.call();
      } catch (error) {
        final message = _messageOf(error);
        store.dispatch(EnrollmentMutationFailedAction(message));
        action.onError?.call(message);
      }
    }).call,
  ];
}

Future<void> _notifyMutation(
  AppDependencies deps,
  String title,
  String body,
) async {
  try {
    await deps.notificationService.showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
    );
  } catch (_) {}
}

String _messageOf(Object error) {
  if (error is AppException) return error.message;
  return error.toString();
}
