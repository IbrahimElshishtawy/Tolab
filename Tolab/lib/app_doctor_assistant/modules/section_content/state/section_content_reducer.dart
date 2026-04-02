import '../../../core/state/async_state.dart';
import 'section_content_actions.dart';
import 'section_content_state.dart';

SectionContentState sectionContentReducer(
  SectionContentState state,
  dynamic action,
) {
  switch (action.runtimeType) {
    case LoadSectionContentAction _:
    case SaveSectionContentAction _:
      return SectionContentState(status: ViewStatus.loading, data: state.data);
    case LoadSectionContentSuccessAction _:
      return SectionContentState(
        status: ViewStatus.success,
        data: (action as LoadSectionContentSuccessAction).items,
      );
    case LoadSectionContentFailureAction _:
      return SectionContentState(
        status: ViewStatus.failure,
        data: state.data,
        error: (action as LoadSectionContentFailureAction).message,
      );
    default:
      return state;
  }
}
