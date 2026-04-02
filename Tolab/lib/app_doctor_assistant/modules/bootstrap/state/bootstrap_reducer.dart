import '../../../core/state/async_state.dart';
import 'bootstrap_actions.dart';
import 'bootstrap_state.dart';

BootstrapState bootstrapReducer(
  BootstrapState state,
  dynamic action,
) {
  switch (action.runtimeType) {
    case BootstrapStartedAction:
      return state.copyWith(status: ViewStatus.loading, clearError: true);
    case BootstrapCompletedAction:
      return state.copyWith(status: ViewStatus.success, clearError: true);
    case BootstrapFailedAction:
      return state.copyWith(
        status: ViewStatus.failure,
        error: (action as BootstrapFailedAction).message,
      );
    default:
      return state;
  }
}
