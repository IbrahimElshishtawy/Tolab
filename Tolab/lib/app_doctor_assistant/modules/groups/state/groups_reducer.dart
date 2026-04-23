import '../../../core/state/async_state.dart';
import 'groups_actions.dart';
import 'groups_state.dart';

GroupsState groupsReducer(GroupsState state, dynamic action) {
  switch (action) {
    case LoadSubjectGroupAction _:
    case SaveGroupPostAction _:
    case DeleteGroupPostAction _:
    case TogglePinnedPostAction _:
      return GroupsState(status: ViewStatus.loading, data: state.data);
    case LoadSubjectGroupSuccessAction action:
      return GroupsState(
        status: ViewStatus.success,
        data: action.group,
      );
    case LoadSubjectGroupFailureAction action:
      return GroupsState(
        status: ViewStatus.failure,
        data: state.data,
        error: action.message,
      );
    default:
      return state;
  }
}
