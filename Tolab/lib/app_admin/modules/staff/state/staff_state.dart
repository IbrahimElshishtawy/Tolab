import 'package:redux/redux.dart';

import '../../../core/services/app_dependencies.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/states/entity_collection_state.dart';
import '../../../state/app_state.dart';
import '../models/staff_admin_models.dart';

typedef StaffState = EntityCollectionState<StaffAdminRecord>;

const StaffState initialStaffState = EntityCollectionState<StaffAdminRecord>();

class LoadStaffAction {}

class StaffLoadedAction {
  StaffLoadedAction(this.items);

  final List<StaffAdminRecord> items;
}

class StaffFailedAction {
  StaffFailedAction(this.message);

  final String message;
}

StaffState staffReducer(StaffState state, dynamic action) {
  switch (action) {
    case LoadStaffAction():
      return state.copyWith(status: LoadStatus.loading, clearError: true);
    case StaffLoadedAction():
      return state.copyWith(status: LoadStatus.success, items: action.items);
    case StaffFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    default:
      return state;
  }
}

List<Middleware<AppState>> createStaffMiddleware(AppDependencies deps) {
  return [
    TypedMiddleware<AppState, LoadStaffAction>((store, action, next) async {
      next(action);
      try {
        store.dispatch(
          StaffLoadedAction(await deps.staffRepository.fetchStaff()),
        );
      } catch (error) {
        store.dispatch(StaffFailedAction(error.toString()));
      }
    }).call,
  ];
}
