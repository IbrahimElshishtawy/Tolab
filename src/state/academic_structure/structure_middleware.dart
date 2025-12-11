import 'package:redux/redux.dart';
import '../app_state.dart';
import 'structure_actions.dart';
import '../../../fake_data/data.dart';

List<Middleware<AppState>> createstructureMiddleware() {
  return [
    TypedMiddleware<AppState, LoadstructureAction>(_loadstructure()),
  ];
}

Middleware<AppState> _loadstructure() {
  return (Store<AppState> store, action, NextDispatcher next) async {
    next(action);
    try {
      store.dispatch(structureLoadedAction(fakeData));
    } catch (e) {
      store.dispatch(structureFailedAction(e.toString()));
    }
  };
}
