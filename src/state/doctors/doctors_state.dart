class doctorsState {
  final bool isLoading;
  final dynamic data;
  final String? error;

  doctorsState({
    required this.isLoading,
    required this.data,
    this.error,
  });

  factory doctorsState.initial() =>
      doctorsState(isLoading: false, data: null);

  doctorsState copyWith({bool? isLoading, dynamic data, String? error}) {
    return doctorsState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error,
    );
  }
}
