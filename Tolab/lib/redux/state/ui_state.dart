class UIState {
  final bool showSplash;
  final bool showIntro;
  final bool isGlobalLoading;
  final String? globalError;

  UIState({
    required this.showSplash,
    required this.showIntro,
    this.isGlobalLoading = false,
    this.globalError,
  });

  factory UIState.initial() {
    return UIState(showSplash: true, showIntro: true);
  }

  UIState copyWith({
    bool? showSplash,
    bool? showIntro,
    bool? isGlobalLoading,
    String? globalError,
  }) {
    return UIState(
      showSplash: showSplash ?? this.showSplash,
      showIntro: showIntro ?? this.showIntro,
      isGlobalLoading: isGlobalLoading ?? this.isGlobalLoading,
      globalError: globalError ?? this.globalError,
    );
  }
}
