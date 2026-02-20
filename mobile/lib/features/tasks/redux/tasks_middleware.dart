import 'package:redux/redux.dart';
import '../../../redux/app_state.dart';
import '../../../config/env.dart';
import '../data/tasks_api.dart';
import '../../../mock/fake_repositories/tasks_fake_repo.dart';
import 'tasks_actions.dart';
import '../data/models.dart';

List<Middleware<AppState>> createTasksMiddlewares() {
  return [
    TypedMiddleware<AppState, FetchTasksAction>(_fetchTasksMiddleware),
    TypedMiddleware<AppState, CreateTaskAction>(_createTaskMiddleware),
    TypedMiddleware<AppState, UpdateTaskAction>(_updateTaskMiddleware),
    TypedMiddleware<AppState, DeleteTaskAction>(_deleteTaskMiddleware),
    TypedMiddleware<AppState, FetchSubmissionsAction>(_fetchSubmissionsMiddleware),
    TypedMiddleware<AppState, GradeSubmissionAction>(_gradeSubmissionMiddleware),
  ];
}

void _fetchTasksMiddleware(Store<AppState> store, FetchTasksAction action, NextDispatcher next) async {
  next(action);

  store.dispatch(FetchTasksStartAction());

  try {
    List<dynamic> tasks;
    if (Env.useMock) {
      final repo = TasksFakeRepo();
      tasks = await repo.getTasks(action.subjectId);
    } else {
      final api = TasksApi();
      final response = await api.getTasks(action.subjectId);
      tasks = response.data;
    }
    store.dispatch(FetchTasksSuccessAction(action.subjectId, tasks.cast()));
  } catch (e) {
    store.dispatch(FetchTasksFailureAction(e.toString()));
  }
}

void _createTaskMiddleware(Store<AppState> store, CreateTaskAction action, NextDispatcher next) async {
  next(action);
  store.dispatch(OperationStartAction());
  try {
    if (Env.useMock) {
      await TasksFakeRepo().createTask(action.subjectId, action.task);
    } else {
      // await TasksApi().createTask(action.subjectId, action.task);
    }
    store.dispatch(OperationSuccessAction());
    store.dispatch(FetchTasksAction(action.subjectId));
  } catch (e) {
    store.dispatch(OperationFailureAction(e.toString()));
  }
}

void _updateTaskMiddleware(Store<AppState> store, UpdateTaskAction action, NextDispatcher next) async {
  next(action);
  store.dispatch(OperationStartAction());
  try {
    if (Env.useMock) {
      await TasksFakeRepo().updateTask(action.task);
    }
    store.dispatch(OperationSuccessAction());
    // We don't have subjectId here easily, maybe we should add it to UpdateTaskAction
    // Or just let the UI handle refresh if needed.
  } catch (e) {
    store.dispatch(OperationFailureAction(e.toString()));
  }
}

void _deleteTaskMiddleware(Store<AppState> store, DeleteTaskAction action, NextDispatcher next) async {
  next(action);
  store.dispatch(OperationStartAction());
  try {
    if (Env.useMock) {
      await TasksFakeRepo().deleteTask(action.taskId);
    }
    store.dispatch(OperationSuccessAction());
    store.dispatch(FetchTasksAction(action.subjectId));
  } catch (e) {
    store.dispatch(OperationFailureAction(e.toString()));
  }
}

void _fetchSubmissionsMiddleware(Store<AppState> store, FetchSubmissionsAction action, NextDispatcher next) async {
  next(action);
  store.dispatch(FetchTasksStartAction()); // Reuse loading for now
  try {
    List<Submission> submissions = [];
    if (Env.useMock) {
      submissions = await TasksFakeRepo().getSubmissions(action.taskId);
    }
    store.dispatch(FetchSubmissionsSuccessAction(action.taskId, submissions));
  } catch (e) {
    store.dispatch(FetchTasksFailureAction(e.toString()));
  }
}

void _gradeSubmissionMiddleware(Store<AppState> store, GradeSubmissionAction action, NextDispatcher next) async {
  next(action);
  store.dispatch(OperationStartAction());
  try {
    if (Env.useMock) {
      await TasksFakeRepo().gradeSubmission(action.submissionId, action.grade);
    }
    store.dispatch(OperationSuccessAction());
    store.dispatch(FetchSubmissionsAction(action.taskId));
  } catch (e) {
    store.dispatch(OperationFailureAction(e.toString()));
  }
}
