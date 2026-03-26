import 'package:redux/redux.dart';

import '../../../core/services/app_dependencies.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/models/academic_models.dart';
import '../../../shared/states/entity_collection_state.dart';
import '../../../state/app_state.dart';

typedef EnrollmentsState = EntityCollectionState<EnrollmentRecord>;

const EnrollmentsState initialEnrollmentsState =
    EntityCollectionState<EnrollmentRecord>();

class LoadEnrollmentsAction {}

class EnrollmentsLoadedAction {
  EnrollmentsLoadedAction(this.items);

  final List<EnrollmentRecord> items;
}

class EnrollmentsFailedAction {
  EnrollmentsFailedAction(this.message);

  final String message;
}

EnrollmentsState enrollmentsReducer(EnrollmentsState state, dynamic action) {
  switch (action) {
    case LoadEnrollmentsAction():
      return state.copyWith(status: LoadStatus.loading, clearError: true);
    case EnrollmentsLoadedAction():
      return state.copyWith(status: LoadStatus.success, items: action.items);
    case EnrollmentsFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    default:
      return state;
  }
}

List<Middleware<AppState>> createEnrollmentsMiddleware(AppDependencies deps) {
  return [
    TypedMiddleware<AppState, LoadEnrollmentsAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        store.dispatch(
          EnrollmentsLoadedAction(
            await deps.enrollmentsRepository.fetchEnrollments(),
          ),
        );
      } catch (error) {
        store.dispatch(EnrollmentsFailedAction(error.toString()));
      }
    }).call,
  ];
}
