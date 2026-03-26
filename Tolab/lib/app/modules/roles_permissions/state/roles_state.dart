import 'package:redux/redux.dart';

import '../../../core/services/app_dependencies.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/models/moderation_models.dart';
import '../../../shared/states/entity_collection_state.dart';
import '../../../state/app_state.dart';

typedef RolesState = EntityCollectionState<RolePermission>;

const RolesState initialRolesState = EntityCollectionState<RolePermission>();

class LoadRolesAction {}

class RolesLoadedAction {
  RolesLoadedAction(this.items);

  final List<RolePermission> items;
}

class RolesFailedAction {
  RolesFailedAction(this.message);

  final String message;
}

RolesState rolesReducer(RolesState state, dynamic action) {
  switch (action) {
    case LoadRolesAction():
      return state.copyWith(status: LoadStatus.loading, clearError: true);
    case RolesLoadedAction():
      return state.copyWith(status: LoadStatus.success, items: action.items);
    case RolesFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    default:
      return state;
  }
}

List<Middleware<AppState>> createRolesMiddleware(AppDependencies deps) {
  return [
    TypedMiddleware<AppState, LoadRolesAction>((store, action, next) async {
      next(action);
      try {
        store.dispatch(
          RolesLoadedAction(await deps.rolesRepository.fetchRoles()),
        );
      } catch (error) {
        store.dispatch(RolesFailedAction(error.toString()));
      }
    }).call,
  ];
}
