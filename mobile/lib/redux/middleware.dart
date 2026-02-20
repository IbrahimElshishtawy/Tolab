import 'package:redux/redux.dart';
import 'app_state.dart';
import 'package:tolab_fci/features/auth/redux/auth_middleware.dart';
import 'package:tolab_fci/features/subjects/redux/subjects_middleware.dart';
import 'package:tolab_fci/features/tasks/redux/tasks_middleware.dart';

List<Middleware<AppState>> createMiddlewares() {
  return [
    ...createAuthMiddlewares(),
    ...createSubjectsMiddlewares(),
    ...createTasksMiddlewares(),
  ];
}
