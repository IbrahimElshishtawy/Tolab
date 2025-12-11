import 'package:redux/redux.dart';
import '../app_state.dart';
import 'doctors_actions.dart';
import '../../../fake_data/data.dart';

List<Middleware<AppState>> createdoctorsMiddleware() {
  return [
    TypedMiddleware<AppState, LoaddoctorsAction>(_loaddoctors()),
  ];
}

Middleware<AppState> _loaddoctors() {
  return (Store<AppState> store, action, NextDispatcher next) async {
    next(action);
    try {
      store.dispatch(doctorsLoadedAction(fakeData));
    } catch (e) {
      store.dispatch(doctorsFailedAction(e.toString()));
    }
  };
}
