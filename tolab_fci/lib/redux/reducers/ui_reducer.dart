import '../state/ui_state.dart';
import '../actions/ui_actions.dart';

UIState uiReducer(UIState state, dynamic action) {
  if (action is FinishSplashAction) {
    return state.copyWith(showSplash: false);
  }

  if (action is FinishIntroAction) {
    return state.copyWith(showIntro: false);
  }
  return state;
}
