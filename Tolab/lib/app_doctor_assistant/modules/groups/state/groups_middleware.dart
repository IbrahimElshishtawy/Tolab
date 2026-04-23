import 'package:redux/redux.dart';

import '../../../state/app_state.dart';
import '../repositories/groups_repository.dart';
import 'groups_actions.dart';

List<Middleware<DoctorAssistantAppState>> createGroupsMiddleware(
  GroupsRepository repository,
) {
  return [
    TypedMiddleware<DoctorAssistantAppState, LoadSubjectGroupAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      try {
        final group = await repository.fetchSubjectGroup(action.subjectId);
        store.dispatch(LoadSubjectGroupSuccessAction(group));
      } catch (error) {
        store.dispatch(LoadSubjectGroupFailureAction(error.toString()));
      }
    }).call,
    TypedMiddleware<DoctorAssistantAppState, SaveGroupPostAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      await repository.savePost(action.subjectId, action.payload);
      store.dispatch(LoadSubjectGroupAction(action.subjectId));
    }).call,
    TypedMiddleware<DoctorAssistantAppState, DeleteGroupPostAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      await repository.deletePost(action.postId);
      store.dispatch(LoadSubjectGroupAction(action.subjectId));
    }).call,
    TypedMiddleware<DoctorAssistantAppState, TogglePinnedPostAction>((
      store,
      action,
      next,
    ) async {
      next(action);
      await repository.togglePin(action.postId);
      store.dispatch(LoadSubjectGroupAction(action.subjectId));
    }).call,
  ];
}
