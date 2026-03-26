import 'package:redux/redux.dart';

import '../../../core/services/app_dependencies.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/models/moderation_models.dart';
import '../../../shared/states/entity_collection_state.dart';
import '../../../state/app_state.dart';

typedef ModerationState = EntityCollectionState<ModerationItem>;

const ModerationState initialModerationState =
    EntityCollectionState<ModerationItem>();

class LoadModerationAction {}

class ModerationLoadedAction {
  ModerationLoadedAction(this.items);

  final List<ModerationItem> items;
}

class ModerationFailedAction {
  ModerationFailedAction(this.message);

  final String message;
}

ModerationState moderationReducer(ModerationState state, dynamic action) {
  switch (action) {
    case LoadModerationAction():
      return state.copyWith(status: LoadStatus.loading, clearError: true);
    case ModerationLoadedAction():
      return state.copyWith(status: LoadStatus.success, items: action.items);
    case ModerationFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    default:
      return state;
  }
}

List<Middleware<AppState>> createModerationMiddleware(AppDependencies deps) {
  return [
    TypedMiddleware<AppState, LoadModerationAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        store.dispatch(
          ModerationLoadedAction(await deps.moderationRepository.fetchItems()),
        );
      } catch (error) {
        store.dispatch(ModerationFailedAction(error.toString()));
      }
    }).call,
  ];
}
