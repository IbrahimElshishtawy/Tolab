import '../../../redux/state/admin_state.dart';
import 'admin_actions.dart';

AdminState adminReducer(AdminState state, dynamic action) {
  if (action is AdminLoadingAction) {
    return state.copyWith(isLoading: action.isLoading);
  }
  if (action is AdminErrorAction) {
    return state.copyWith(error: action.error, isLoading: false);
  }
  if (action is FetchUsersSuccessAction) {
    final List<dynamic> updatedUsers = state.userPage == 1
      ? action.users
      : [...state.users, ...action.users];
    return state.copyWith(
      users: updatedUsers,
      hasMoreUsers: action.hasMore,
      userPage: state.userPage + 1,
      isLoading: false,
      error: null,
    );
  }
  if (action is FetchAdminSubjectsSuccessAction) {
    return state.copyWith(
      subjects: action.subjects,
      isLoading: false,
      error: null,
    );
  }
  if (action is FetchAdminOfferingsSuccessAction) {
    return state.copyWith(
      offerings: action.offerings,
      isLoading: false,
      error: null,
    );
  }
  return state;
}
