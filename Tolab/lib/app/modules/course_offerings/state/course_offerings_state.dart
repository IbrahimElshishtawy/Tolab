import 'package:redux/redux.dart';

import '../../../core/services/app_dependencies.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/models/academic_models.dart';
import '../../../shared/states/entity_collection_state.dart';
import '../../../state/app_state.dart';

typedef CourseOfferingsState = EntityCollectionState<CourseOfferingModel>;

const CourseOfferingsState initialCourseOfferingsState =
    EntityCollectionState<CourseOfferingModel>();

class LoadCourseOfferingsAction {}

class CourseOfferingsLoadedAction {
  CourseOfferingsLoadedAction(this.items);

  final List<CourseOfferingModel> items;
}

class CourseOfferingsFailedAction {
  CourseOfferingsFailedAction(this.message);

  final String message;
}

CourseOfferingsState courseOfferingsReducer(
  CourseOfferingsState state,
  dynamic action,
) {
  switch (action) {
    case LoadCourseOfferingsAction():
      return state.copyWith(status: LoadStatus.loading, clearError: true);
    case CourseOfferingsLoadedAction():
      return state.copyWith(status: LoadStatus.success, items: action.items);
    case CourseOfferingsFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    default:
      return state;
  }
}

List<Middleware<AppState>> createCourseOfferingsMiddleware(
  AppDependencies deps,
) {
  return [
    TypedMiddleware<AppState, LoadCourseOfferingsAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        store.dispatch(
          CourseOfferingsLoadedAction(
            await deps.courseOfferingsRepository.fetchCourseOfferings(),
          ),
        );
      } catch (error) {
        store.dispatch(CourseOfferingsFailedAction(error.toString()));
      }
    }).call,
  ];
}
