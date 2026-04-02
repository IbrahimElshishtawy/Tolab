import '../../../core/models/academic_models.dart';
import '../../../core/state/async_state.dart';
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
    case LoadSubjectDetailAction _:
      return state.copyWith(
        detail: const AsyncState<SubjectModel>(status: ViewStatus.loading),
      );
    case LoadSubjectDetailSuccessAction action:
      return state.copyWith(
        detail: AsyncState<SubjectModel>(
          status: ViewStatus.success,
          data: action.subject,
        ),
      );
    default:
      return state;
  }
}
