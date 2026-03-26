import 'package:redux/redux.dart';

import '../../../core/services/app_dependencies.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/models/academic_models.dart';
import '../../../shared/states/entity_collection_state.dart';
import '../../../state/app_state.dart';

typedef DepartmentsState = EntityCollectionState<DepartmentModel>;

const DepartmentsState initialDepartmentsState =
    EntityCollectionState<DepartmentModel>();

class LoadDepartmentsAction {}

class DepartmentsLoadedAction {
  DepartmentsLoadedAction(this.items);

  final List<DepartmentModel> items;
}

class DepartmentsFailedAction {
  DepartmentsFailedAction(this.message);

  final String message;
}

DepartmentsState departmentsReducer(DepartmentsState state, dynamic action) {
  switch (action) {
    case LoadDepartmentsAction():
      return state.copyWith(status: LoadStatus.loading, clearError: true);
    case DepartmentsLoadedAction():
      return state.copyWith(status: LoadStatus.success, items: action.items);
    case DepartmentsFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    default:
      return state;
  }
}

List<Middleware<AppState>> createDepartmentsMiddleware(AppDependencies deps) {
  return [
    TypedMiddleware<AppState, LoadDepartmentsAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        store.dispatch(
          DepartmentsLoadedAction(
            await deps.departmentsRepository.fetchDepartments(),
          ),
        );
      } catch (error) {
        store.dispatch(DepartmentsFailedAction(error.toString()));
      }
    }).call,
  ];
}
