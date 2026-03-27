import 'package:redux/redux.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/app_dependencies.dart';
import '../../../state/app_state.dart';
import 'course_offerings_actions.dart';

List<Middleware<AppState>> createCourseOfferingsMiddleware(
  AppDependencies deps,
) {
  return [
    TypedMiddleware<AppState, FetchCourseOfferingsAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final state = store.state.courseOfferingsState;
        final bundle = await deps.courseOfferingsRepository.fetchOfferings(
          filters: state.filters,
          pagination: state.pagination,
        );
        store.dispatch(CourseOfferingsLoadedAction(bundle));
      } catch (error) {
        store.dispatch(CourseOfferingsFailedAction(_messageOf(error)));
      }
    }).call,
    TypedMiddleware<AppState, FetchCourseOfferingDetailsAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final offering = await deps.courseOfferingsRepository
            .fetchOfferingDetails(action.offeringId);
        store.dispatch(CourseOfferingDetailsLoadedAction(offering));
      } catch (error) {
        store.dispatch(CourseOfferingDetailsFailedAction(_messageOf(error)));
      }
    }).call,
    TypedMiddleware<AppState, CreateCourseOfferingAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const CourseOfferingMutationStartedAction());
      try {
        final state = store.state.courseOfferingsState;
        final result = await deps.courseOfferingsRepository.createOffering(
          payload: action.payload,
          pagination: state.pagination,
        );
        store.dispatch(CourseOfferingMutationSucceededAction(result));
        action.onSuccess?.call();
      } catch (error) {
        final message = _messageOf(error);
        store.dispatch(CourseOfferingMutationFailedAction(message));
        action.onError?.call(message);
      }
    }).call,
    TypedMiddleware<AppState, UpdateCourseOfferingAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const CourseOfferingMutationStartedAction());
      try {
        final state = store.state.courseOfferingsState;
        final result = await deps.courseOfferingsRepository.updateOffering(
          offeringId: action.offeringId,
          payload: action.payload,
          pagination: state.pagination,
        );
        store.dispatch(CourseOfferingMutationSucceededAction(result));
        action.onSuccess?.call();
      } catch (error) {
        final message = _messageOf(error);
        store.dispatch(CourseOfferingMutationFailedAction(message));
        action.onError?.call(message);
      }
    }).call,
    TypedMiddleware<AppState, DeleteCourseOfferingAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      store.dispatch(const CourseOfferingMutationStartedAction());
      try {
        final state = store.state.courseOfferingsState;
        final result = await deps.courseOfferingsRepository.deleteOffering(
          offeringId: action.offeringId,
          pagination: state.pagination,
        );
        store.dispatch(CourseOfferingMutationSucceededAction(result));
        action.onSuccess?.call();
      } catch (error) {
        final message = _messageOf(error);
        store.dispatch(CourseOfferingMutationFailedAction(message));
        action.onError?.call(message);
      }
    }).call,
  ];
}

String _messageOf(Object error) {
  if (error is AppException) return error.message;
  return error.toString();
}
