import 'package:redux/redux.dart';

import '../../../core/services/app_dependencies.dart';
import '../../../shared/enums/load_status.dart';
import '../../../shared/models/academic_models.dart';
import '../../../shared/states/entity_collection_state.dart';
import '../../../state/app_state.dart';

typedef SectionsState = EntityCollectionState<SectionModel>;

const SectionsState initialSectionsState =
    EntityCollectionState<SectionModel>();

class LoadSectionsAction {}

class SectionsLoadedAction {
  SectionsLoadedAction(this.items);

  final List<SectionModel> items;
}

class SectionsFailedAction {
  SectionsFailedAction(this.message);

  final String message;
}

SectionsState sectionsReducer(SectionsState state, dynamic action) {
  switch (action) {
    case LoadSectionsAction():
      return state.copyWith(status: LoadStatus.loading, clearError: true);
    case SectionsLoadedAction():
      return state.copyWith(status: LoadStatus.success, items: action.items);
    case SectionsFailedAction():
      return state.copyWith(
        status: LoadStatus.failure,
        errorMessage: action.message,
      );
    default:
      return state;
  }
}

List<Middleware<AppState>> createSectionsMiddleware(AppDependencies deps) {
  return [
    TypedMiddleware<AppState, LoadSectionsAction>((store, action, next) async {
      next(action);
      try {
        store.dispatch(
          SectionsLoadedAction(await deps.sectionsRepository.fetchSections()),
        );
      } catch (error) {
        store.dispatch(SectionsFailedAction(error.toString()));
      }
    }).call,
  ];
}
