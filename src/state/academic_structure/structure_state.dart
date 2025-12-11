class structureState {
  final bool isLoading;
  final dynamic data;
  final String? error;

  structureState({
    required this.isLoading,
    required this.data,
    this.error,
  });

  factory structureState.initial() =>
      structureState(isLoading: false, data: null);

  structureState copyWith({bool? isLoading, dynamic data, String? error}) {
    return structureState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error,
    );
  }
}
