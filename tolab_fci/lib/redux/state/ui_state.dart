class UIState {
  final bool showSplash;
  final bool showIntro;

  UIState({required this.showSplash, required this.showIntro});

  factory UIState.initial() {
    return UIState(showSplash: false, showIntro: false);
  }

  UIState copyWith({bool? showSplash, bool? showIntro}) {
    return UIState(
      showSplash: showSplash ?? this.showSplash,
      showIntro: showIntro ?? this.showIntro,
    );
  }
}
