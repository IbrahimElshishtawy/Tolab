import 'package:redux/redux.dart';
import '../../core/api/api_service_assistants.dart';
import '../app_state.dart';
import 'assistants_actions.dart';

List<Middleware<AppState>> createAssistantsMiddleware(
  ApiServiceAssistants api,
) {
  return [
    TypedMiddleware<AppState, LoadAssistantsAction>(_loadAssistants(api)).call,
  ];
}

Middleware<AppState> _loadAssistants(ApiServiceAssistants api) {
  return (Store<AppState> store, action, NextDispatcher next) async {
    next(action);

    try {
      final data = await api.fetchAssistants();
      store.dispatch(AssistantsLoadedAction(data));
    } catch (e) {
      store.dispatch(AssistantsFailedAction(e.toString()));
    }
  };
}
