import '../../../core/models/academic_models.dart';
import '../../../core/state/async_state.dart';
import '../models/subject_workspace_models.dart';
import 'subjects_actions.dart';
import 'subjects_state.dart';

SubjectsState subjectsReducer(SubjectsState state, dynamic action) {
  switch (action) {
    case LoadSubjectsAction _:
      return state.copyWith(
        list: const AsyncState<List<SubjectModel>>(status: ViewStatus.loading),
      );
    case LoadSubjectsSuccessAction action:
      return state.copyWith(
        list: AsyncState<List<SubjectModel>>(
          status: ViewStatus.success,
          data: action.items,
        ),
      );
    case LoadSubjectsFailureAction action:
      return state.copyWith(
        list: AsyncState<List<SubjectModel>>(
          status: ViewStatus.failure,
          error: action.message,
        ),
      );
    case LoadSubjectWorkspaceAction _:
      return state.copyWith(
        workspace: const AsyncState<SubjectWorkspaceModel>(
          status: ViewStatus.loading,
        ),
      );
    case LoadSubjectWorkspaceSuccessAction action:
      return state.copyWith(
        workspace: AsyncState<SubjectWorkspaceModel>(
          status: ViewStatus.success,
          data: action.workspace,
        ),
      );
    case LoadSubjectWorkspaceFailureAction action:
      return state.copyWith(
        workspace: AsyncState<SubjectWorkspaceModel>(
          status: ViewStatus.failure,
          error: action.message,
        ),
      );
    default:
      return state;
  }
}
