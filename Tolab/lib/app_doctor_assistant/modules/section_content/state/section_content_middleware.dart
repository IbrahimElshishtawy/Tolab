import 'package:redux/redux.dart';

import '../../../state/app_state.dart';
import '../repositories/section_content_repository.dart';
import 'section_content_actions.dart';

List<Middleware<DoctorAssistantAppState>> createSectionContentMiddleware(
  SectionContentRepository repository,
) {
  return [
    TypedMiddleware<DoctorAssistantAppState, LoadSectionContentAction>(
      (store, action, next) async {
        next(action);
        try {
          final items = await repository.fetchSectionContent();
          store.dispatch(LoadSectionContentSuccessAction(items));
        } catch (error) {
          store.dispatch(LoadSectionContentFailureAction(error.toString()));
        }
      },
    ),
    TypedMiddleware<DoctorAssistantAppState, SaveSectionContentAction>(
      (store, action, next) async {
        next(action);
        await repository.saveSectionContent(
          (action as SaveSectionContentAction).payload,
        );
        store.dispatch(LoadSectionContentAction());
      },
    ),
  ];
}
