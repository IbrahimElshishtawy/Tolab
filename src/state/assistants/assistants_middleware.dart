import 'package:redux/redux.dart';
import '../app_state.dart';
import 'assistants_actions.dart';
import '../../../fake_data/data.dart';

List<Middleware<AppState>> createassistantsMiddleware() {
  return [
    TypedMiddleware<AppState, LoadassistantsAction>(_loadassistants()),
  ];
}

Middleware<AppState> _loadassistants() {
  return (Store<AppState> store, action, NextDispatcher next) async {
    next(action);
    try {
      store.dispatch(assistantsLoadedAction(fakeData));
    } catch (e) {
      store.dispatch(assistantsFailedAction(e.toString()));
    }
  };
}
