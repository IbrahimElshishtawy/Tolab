import 'package:redux/redux.dart';
import '../../../redux/app_state.dart';
import '../../../config/env.dart';
import 'admin_actions.dart';

List<Middleware<AppState>> createAdminMiddlewares() {
  return [
    TypedMiddleware<AppState, FetchUsersAction>(_fetchUsersMiddleware).call,
    TypedMiddleware<AppState, FetchAdminSubjectsAction>(_fetchSubjectsMiddleware).call,
  ];
}

void _fetchUsersMiddleware(Store<AppState> store, FetchUsersAction action, NextDispatcher next) async {
  next(action);
  store.dispatch(AdminLoadingAction(true));
  try {
    // Mock for now until API is ready
    await Future.delayed(const Duration(seconds: 1));
    final users = List.generate(10, (i) => {'id': i, 'name': 'User ${i + 1}', 'email': 'user$i@uni.edu'});
    store.dispatch(FetchUsersSuccessAction(users, false));
  } catch (e) {
    store.dispatch(AdminErrorAction(e.toString()));
  }
}

void _fetchSubjectsMiddleware(Store<AppState> store, FetchAdminSubjectsAction action, NextDispatcher next) async {
  next(action);
  store.dispatch(AdminLoadingAction(true));
  try {
    await Future.delayed(const Duration(seconds: 1));
    final subjects = List.generate(8, (i) => {'id': i, 'name': 'Subject ${i+1}', 'code': 'SUB${100+i}'});
    store.dispatch(FetchAdminSubjectsSuccessAction(subjects));
  } catch (e) {
    store.dispatch(AdminErrorAction(e.toString()));
  }
}
