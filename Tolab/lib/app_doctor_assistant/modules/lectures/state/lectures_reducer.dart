// ignore_for_file: type_literal_in_constant_pattern

import '../../../core/state/async_state.dart';
import 'lectures_actions.dart';
import 'lectures_state.dart';

LecturesState lecturesReducer(LecturesState state, dynamic action) {
  switch (action.runtimeType) {
    case LoadLecturesAction:
    case SaveLectureAction:
    case DeleteLectureAction:
    case PublishLectureAction:
      return LecturesState(status: ViewStatus.loading, data: state.data);
    case LoadLecturesSuccessAction:
      return LecturesState(
        status: ViewStatus.success,
        data: (action as LoadLecturesSuccessAction).items,
      );
    case LoadLecturesFailureAction:
      return LecturesState(
        status: ViewStatus.failure,
        data: state.data,
        error: (action as LoadLecturesFailureAction).message,
      );
    default:
      return state;
  }
}
