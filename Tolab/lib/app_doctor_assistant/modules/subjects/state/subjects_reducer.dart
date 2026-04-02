import '../../../core/state/async_state.dart';
import 'subjects_actions.dart';
import 'subjects_state.dart';

SubjectsState subjectsReducer(SubjectsState state, dynamic action) {
  switch (action.runtimeType) {
    case LoadSubjectsAction:
      return state.copyWith(
        list: const AsyncState<List<SubjectModel>>(status: ViewStatus.loading),
      );
    case LoadSubjectsSuccessAction:
      return state.copyWith(
        list: AsyncState<List<SubjectModel>>(
          status: ViewStatus.success,
          data: (action as LoadSubjectsSuccessAction).items,
        ),
      );
    case LoadSubjectsFailureAction:
      return state.copyWith(
        list: AsyncState<List<SubjectModel>>(
          status: ViewStatus.failure,
          error: (action as LoadSubjectsFailureAction).message,
        ),
      );
    case LoadSubjectDetailAction:
      return state.copyWith(
        detail: const AsyncState<SubjectModel>(status: ViewStatus.loading),
      );
    case LoadSubjectDetailSuccessAction:
      return state.copyWith(
        detail: AsyncState<SubjectModel>(
          status: ViewStatus.success,
          data: (action as LoadSubjectDetailSuccessAction).subject,
        ),
      );
    default:
      return state;
  }
}
