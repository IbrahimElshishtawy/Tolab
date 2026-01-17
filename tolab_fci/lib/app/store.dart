import 'package:redux/redux.dart';
import 'package:tolab_fci/redux/reducers/root_reducer.dart';
import 'middlewares.dart';
import '../redux/state/app_state.dart';

Store<AppState> createStore() {
  return Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
    middleware: createAppMiddlewares(),
  );
}
