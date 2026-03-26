import 'package:redux/redux.dart';

import '../../../core/services/app_dependencies.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/models/content_models.dart';
import '../../../shared/states/entity_collection_state.dart';
import '../../../state/app_state.dart';

typedef ContentState = EntityCollectionState<ContentItem>;

const ContentState initialContentState = EntityCollectionState<ContentItem>();

class LoadContentAction {}

class ContentLoadedAction {
  ContentLoadedAction(this.items);

  final List<ContentItem> items;
}

class ContentFailedAction {
  ContentFailedAction(this.message);

  final String message;
}

ContentState contentReducer(ContentState state, dynamic action) {
  switch (action) {
    case LoadContentAction():
      return state.copyWith(status: LoadStatus.loading, clearError: true);
    case ContentLoadedAction():
      return state.copyWith(status: LoadStatus.success, items: action.items);
    case ContentFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    default:
      return state;
  }
}

List<Middleware<AppState>> createContentMiddleware(AppDependencies deps) {
  return [
    TypedMiddleware<AppState, LoadContentAction>((store, action, next) async {
      next(action);
      try {
        store.dispatch(
          ContentLoadedAction(await deps.contentRepository.fetchContent()),
        );
      } catch (error) {
        store.dispatch(ContentFailedAction(error.toString()));
      }
    }).call,
  ];
}
