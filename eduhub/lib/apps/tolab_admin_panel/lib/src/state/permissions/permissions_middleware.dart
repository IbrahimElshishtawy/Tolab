// ignore_for_file: file_names

import 'package:redux/redux.dart';
import '../app_state.dart';
import 'permissions_actions.dart';

class PermissionsMiddleware {
  static List<Middleware<AppState>> permissions() {
    return [
      TypedMiddleware<AppState, LoadPermissionsAction>(_loadPermissions).call,
      TypedMiddleware<AppState, UpdatePermissionsAction>(
        _updatePermissions,
      ).call,
    ];
  }

  static void _loadPermissions(
    Store<AppState> store,
    LoadPermissionsAction action,
    NextDispatcher next,
  ) async {
    next(action);

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final permissions = <String, bool>{
        "canViewStudents": true,
        "canEditStudents": false,
        "canDeleteStudents": false,
        "canViewDoctors": true,
        "canEditDoctors": false,
      };

      store.dispatch(PermissionsLoadedAction(permissions));
    } catch (e) {
      store.dispatch(PermissionsFailedAction(e.toString()));
    }
  }

  static void _updatePermissions(
    Store<AppState> store,
    UpdatePermissionsAction action,
    NextDispatcher next,
  ) {
    next(action);
  }
}
