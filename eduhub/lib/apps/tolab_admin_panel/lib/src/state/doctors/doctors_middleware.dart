// TODO Implement this library.
import 'package:redux/redux.dart';
import '../../core/api/api_service_doctors.dart';
import '../app_state.dart';
import 'doctors_actions.dart';

List<Middleware<AppState>> createDoctorsMiddleware(ApiServiceDoctors api) {
  return [TypedMiddleware<AppState, LoadDoctorsAction>(_loadDoctors(api)).call];
}

Middleware<AppState> _loadDoctors(ApiServiceDoctors api) {
  return (Store<AppState> store, action, NextDispatcher next) async {
    next(action);

    try {
      final data = await api.fetchDoctors();
      store.dispatch(DoctorsLoadedAction(data));
    } catch (e) {
      store.dispatch(DoctorsFailedAction(e.toString()));
    }
  };
}
