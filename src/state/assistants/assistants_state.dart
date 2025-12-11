class assistantsState {
  final bool isLoading;
  final dynamic data;
  final String? error;

  assistantsState({
    required this.isLoading,
    required this.data,
    this.error,
  });

  factory assistantsState.initial() =>
      assistantsState(isLoading: false, data: null);

  assistantsState copyWith({bool? isLoading, dynamic data, String? error}) {
    return assistantsState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error,
    );
  }
}
