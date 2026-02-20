// ignore_for_file: file_names

import 'package:redux/redux.dart';
import 'package:tolab_fci/redux/actions/ui_actions.dart';

class UIState {
  final bool showSplash;
  final bool showIntro;

  UIState({required this.showSplash, required this.showIntro});

  factory UIState.initial() {
    return UIState(
      showSplash: true, // 👈 أول ما التطبيق يفتح
      showIntro: false, // 👈 خليه false مؤقتًا
    );
  }

  UIState copyWith({bool? showSplash, bool? showIntro}) {
    return UIState(
      showSplash: showSplash ?? this.showSplash,
      showIntro: showIntro ?? this.showIntro,
    );
  }
}

final uiReducer = combineReducers<UIState>([
  TypedReducer<UIState, ShowSplashAction>(_showSplash).call,
  TypedReducer<UIState, HideSplashAction>(_hideSplash).call,
  TypedReducer<UIState, ShowIntroAction>(_showIntro).call,
  TypedReducer<UIState, HideIntroAction>(_hideIntro).call,
]);

UIState _showSplash(UIState state, ShowSplashAction action) {
  return state.copyWith(showSplash: true);
}

UIState _hideSplash(UIState state, HideSplashAction action) {
  return state.copyWith(showSplash: false);
}

UIState _showIntro(UIState state, ShowIntroAction action) {
  return state.copyWith(showIntro: true);
}

UIState _hideIntro(UIState state, HideIntroAction action) {
  return state.copyWith(showIntro: false);
}
